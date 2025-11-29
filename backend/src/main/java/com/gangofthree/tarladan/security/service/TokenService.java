package com.gangofthree.tarladan.security.service;

import com.gangofthree.tarladan.security.jwt.JwtUtil;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.util.Set;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

/**
 * Token Yönetim Servisi (Redis Entegrasyonu)
 * * Bu sınıf, JWT'lerin (Access ve Refresh) yaşam döngüsünü Redis üzerinde yönetir.
 * * Normalde JWT sunucuda saklanmaz ama biz "Logout" (Çıkış) özelliği ve
 * "Güvenli Yenileme" (Refresh) yapabilmek için tokenları Redis'e kaydediyoruz (Whitelist yöntemi).
 */
@Service
public class TokenService {

    private final StringRedisTemplate redisTemplate;
    private final JwtUtil jwtUtil;

    // Access Token ömrü (Örn: 15 dk)
    @Value("${jwt.access-token-ttl-minutes}")
    private long accessTokenTtlMinutes;

    // Refresh Token ömrü (Örn: 7 gün)
    @Value("${jwt.refresh-token-ttl-days}")
    private long refreshTokenTtlDays;

    // Redis Anahtar Ön Ekleri (Key Prefixes)
    // Access Tokenlar: "access:123" (userId) şeklinde saklanır.
    private static final String ACCESS_TOKEN_KEY_PREFIX = "access:";
    // Refresh Tokenlar: "refresh:uuid-string" şeklinde saklanır.
    private static final String REFRESH_TOKEN_KEY_PREFIX = "refresh:";

    public TokenService(StringRedisTemplate redisTemplate, JwtUtil jwtUtil) {
        this.redisTemplate = redisTemplate;
        this.jwtUtil = jwtUtil;
    }

    /**
     * Access Token'ı Redis'e Kaydet (Whitelist)
     * * Kullanıcı giriş yaptığında veya token yenilediğinde çağrılır.
     * * Token'ı Redis'e yazarız. Filtre (JwtAuthFilter) her istekte buraya bakar.
     * Eğer token Redis'te yoksa (süresi bitmiş veya silinmişse), istek reddedilir.
     */
    public void saveAccessToken(Long userId, String accessToken) {
        String key = ACCESS_TOKEN_KEY_PREFIX + userId;
        // Token'ı kullanıcının ID'si ile eşleştirip süreli olarak kaydediyoruz.
        redisTemplate.opsForValue().set(key, accessToken, accessTokenTtlMinutes, TimeUnit.MINUTES);
    }

    /**
     * Refresh Token Oluştur veya Güncelle (Session Management)
     * * Access Token kısa ömürlüdür (15-30 dk). Refresh Token ise uzun ömürlüdür (7-30 gün).
     * * Kullanıcının Access Token'ı bittiğinde, Refresh Token sayesinde tekrar şifre girmeden
     * yeni Access Token alır.
     */
    public String createOrUpdateRefreshToken(Long userId, Long domainId, String accessToken) {
        // 1. Kontrol: Bu kullanıcının zaten aktif bir oturumu (Refresh Token'ı) var mı?
        String existingRefreshToken = findRefreshTokenByUserId(userId);

        String refreshToken;
        if (existingRefreshToken != null) {
            // 2. Senaryo: Var olan oturumu güncelle (Rotation/Extension)
            // Refresh Token ID'si (UUID) değişmez ama işaret ettiği Access Token güncellenir.
            // Böylece kullanıcının oturum süresi uzar.
            refreshToken = existingRefreshToken;

            // Format: "userId:domainId:accessToken"
            String newValue = userId + ":" + domainId + ":" + accessToken;

            redisTemplate.opsForValue().set(REFRESH_TOKEN_KEY_PREFIX + refreshToken, newValue, refreshTokenTtlDays, TimeUnit.DAYS);
        } else {
            // 3. Senaryo: İlk defa oturum açıyor, yeni Refresh Token üret.
            refreshToken = UUID.randomUUID().toString();
            String value = userId + ":" + domainId + ":" + accessToken;
            redisTemplate.opsForValue().set(REFRESH_TOKEN_KEY_PREFIX + refreshToken, value, refreshTokenTtlDays, TimeUnit.DAYS);
        }

        return refreshToken;
    }

    /**
     * Kullanıcı ID'sine göre Refresh Token Bul
     * * NOT: Redis'te 'keys' komutu performansı etkileyebilir (O(N)).
     * Prod ortamında binlerce kullanıcı varsa 'SCAN' komutu veya Set yapısı kullanmak daha iyidir.
     * Şimdilik development için uygundur.
     */
    private String findRefreshTokenByUserId(Long userId) {
        // "refresh:*" ile başlayan tüm anahtarları getir (Pahalı işlem!)
        Set<String> keys = redisTemplate.keys(REFRESH_TOKEN_KEY_PREFIX + "*");
        if (keys == null) return null;

        // Tüm anahtarları gez, değeri "userId:" ile başlayan var mı bak.
        for (String key : keys) {
            String value = redisTemplate.opsForValue().get(key);
            if (value != null && value.startsWith(userId + ":")) {
                // Bulduysan "refresh:" öneki olmadan UUID'yi döndür.
                return key.replace(REFRESH_TOKEN_KEY_PREFIX, "");
            }
        }
        return null;
    }

    /**
     * Access Token Geçerlilik Kontrolü (The Gatekeeper Check)
     * * JwtAuthFilter bu metodu çağırır.
     * * Gelen token, Redis'te kayıtlı olan token ile birebir aynı mı?
     * * Eğer kullanıcı "Logout" yapmışsa Redis'teki silinmiştir ve bu metot false döner.
     */
    public boolean isAccessTokenValidInRedis(Long userId, String token) {
        String key = ACCESS_TOKEN_KEY_PREFIX + userId;
        String storedToken = redisTemplate.opsForValue().get(key);
        // Token var mı VE gelen token ile eşleşiyor mu?
        return storedToken != null && storedToken.equals(token);
    }

    /**
     * Access Token'a karşılık gelen Refresh Token'ı bul
     * * Token yenileme (Refresh) işlemi sırasında, eski access token'ı kimin oluşturduğunu bulmak için kullanılır.
     */
    public String findRefreshTokenByAccessToken(String accessToken) {
        Set<String> keys = redisTemplate.keys(REFRESH_TOKEN_KEY_PREFIX + "*");
        if (keys == null) return null;

        for (String key : keys) {
            String value = redisTemplate.opsForValue().get(key);
            // Value formatı: "userId:domainId:accessToken"
            // Sonu bizim accessToken ile bitiyor mu?
            if (value != null && value.endsWith(":" + accessToken)) {
                return key.replace(REFRESH_TOKEN_KEY_PREFIX, "");
            }
        }
        return null;
    }

    /**
     * Helper: Refresh Token değerini parse et
     * @return [userId, domainId, accessToken] dizisi
     */
    public String[] getRefreshData(String refreshToken) {
        String value = redisTemplate.opsForValue().get(REFRESH_TOKEN_KEY_PREFIX + refreshToken);
        return value != null ? value.split(":") : null;
    }

    /**
     * SESSİZ YENİLEME (Silent Refresh Logic)
     * * Kullanıcının Access Token süresi bitmişse (JwtAuthFilter yakalar),
     * * Bu metot devreye girer ve Refresh Token'ı kontrol eder.
     * * Refresh Token hala sağlamsa, kullanıcıya hissettirmeden yeni bir Access Token üretir.
     */
    public String refreshAccessTokenIfValid(String expiredAccessToken, String role) {
        // 1. Bu bitmiş token'a ait bir refresh token var mı?
        String refreshToken = findRefreshTokenByAccessToken(expiredAccessToken);
        if (refreshToken == null) return null; // Yoksa, oturum tamamen bitmiş. Login'e git.

        // 2. Refresh token verilerini çöz
        String[] data = getRefreshData(refreshToken);
        if (data == null || data.length < 3) return null;

        Long userId = Long.parseLong(data[0]);
        Long domainId = Long.parseLong(data[1]);

        // 3. YENİ Access Token üret
        String newAccessToken = jwtUtil.generateAccessToken(userId, role, domainId);

        // 4. Redis'i güncelle (Eski access token silinir, yenisi yazılır)
        saveAccessToken(userId, newAccessToken);

        // 5. Refresh Token'ın içindeki access token bilgisini de güncelle
        String newValue = userId + ":" + domainId + ":" + newAccessToken;
        redisTemplate.opsForValue().set(REFRESH_TOKEN_KEY_PREFIX + refreshToken, newValue, refreshTokenTtlDays, TimeUnit.DAYS);

        return newAccessToken;
    }

    /**
     * ÇIKIŞ YAP (Logout)
     * * Kullanıcı çıkış dediğinde Redis'teki hem Access hem Refresh tokenları silinir.
     * * Böylece o tokenlar teknik olarak geçerli görünse bile (JWT süresi bitmese bile),
     * * Redis'te olmadıkları için JwtAuthFilter onları reddeder.
     */
    public void logoutByAccessToken(String accessToken) {
        if (accessToken == null || accessToken.isEmpty()) return;

        try {
            Long userId = jwtUtil.extractAllClaims(accessToken).get(JwtUtil.USER_ID, Long.class);

            // Access token sil (Whitelist'ten çıkar)
            redisTemplate.delete(ACCESS_TOKEN_KEY_PREFIX + userId);

            // Bu access token’a bağlı refresh token’ı da bul ve sil
            String refreshToken = findRefreshTokenByAccessToken(accessToken);
            if (refreshToken != null) {
                redisTemplate.delete(REFRESH_TOKEN_KEY_PREFIX + refreshToken);
            }

            // Garanti olsun diye kullanıcıya ait kalan tüm kırıntıları temizle
            removeAllUserTokensFromRedis(userId);

        } catch (Exception e) {
            // Token bozuksa bile Redis'ten temizlemeye çalış
            String refreshToken = findRefreshTokenByAccessToken(accessToken);
            if (refreshToken != null)
                redisTemplate.delete(REFRESH_TOKEN_KEY_PREFIX + refreshToken);
        }
    }

    /**
     * Temizlik Robotu
     * * Bir kullanıcıya ait olası tüm refresh tokenları siler.
     * * "Tüm cihazlardan çıkış yap" özelliği için kullanılabilir.
     */
    private void removeAllUserTokensFromRedis(Long userId) {
        if (userId == null) return;

        Set<String> keys = redisTemplate.keys(REFRESH_TOKEN_KEY_PREFIX + "*");
        if (keys == null) return;

        for (String key : keys) {
            String value = redisTemplate.opsForValue().get(key);
            if (value != null && value.startsWith(userId + ":")) {
                redisTemplate.delete(key);
            }
        }
    }
}