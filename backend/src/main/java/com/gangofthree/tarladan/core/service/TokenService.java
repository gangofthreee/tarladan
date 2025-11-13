package com.gangofthree.tarladan.core.service;

import com.gangofthree.tarladan.common.utils.JwtUtil;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.util.Set;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

@Service
public class TokenService {

    private final StringRedisTemplate redisTemplate;
    private final JwtUtil jwtUtil;

    @Value("${jwt.access-token-ttl-minutes}")
    private long accessTokenTtlMinutes;

    @Value("${jwt.refresh-token-ttl-days}")
    private long refreshTokenTtlDays;

    private static final String ACCESS_TOKEN_KEY_PREFIX = "access:";   // access:{userId}
    private static final String REFRESH_TOKEN_KEY_PREFIX = "refresh:"; // refresh:{refreshToken}

    public TokenService(StringRedisTemplate redisTemplate, JwtUtil jwtUtil) {
        this.redisTemplate = redisTemplate;
        this.jwtUtil = jwtUtil;
    }

    //  Kullanıcıya ait access token kaydet
    public void saveAccessToken(Long userId, String accessToken) {
        String key = ACCESS_TOKEN_KEY_PREFIX + userId;
        redisTemplate.opsForValue().set(key, accessToken, accessTokenTtlMinutes, TimeUnit.MINUTES);
    }

    //  Eğer refresh token zaten varsa yeniden oluşturma, sadece value’sunu güncelle
    public String createOrUpdateRefreshToken(Long userId, Long domainId, String accessToken) {
        // 1️⃣ Önce bu kullanıcıya ait refresh token Redis'te var mı kontrol et
        String existingRefreshToken = findRefreshTokenByUserId(userId);

        String refreshToken;
        if (existingRefreshToken != null) {
            // 2️⃣ Varsa, sadece value’sunu (accessToken) güncelle
            refreshToken = existingRefreshToken;
            String newValue = userId + ":" + domainId + ":" + accessToken;
            redisTemplate.opsForValue().set(REFRESH_TOKEN_KEY_PREFIX + refreshToken, newValue, refreshTokenTtlDays, TimeUnit.DAYS);
        } else {
            // 3️⃣ Yoksa, yeni refresh token oluştur
            refreshToken = UUID.randomUUID().toString();
            String value = userId + ":" + domainId + ":" + accessToken;
            redisTemplate.opsForValue().set(REFRESH_TOKEN_KEY_PREFIX + refreshToken, value, refreshTokenTtlDays, TimeUnit.DAYS);
        }

        return refreshToken;
    }

    //  Kullanıcıya ait refresh token var mı bul
    private String findRefreshTokenByUserId(Long userId) {
        Set<String> keys = redisTemplate.keys(REFRESH_TOKEN_KEY_PREFIX + "*");
        if (keys == null) return null;

        for (String key : keys) {
            String value = redisTemplate.opsForValue().get(key);
            if (value != null && value.startsWith(userId + ":")) {
                return key.replace(REFRESH_TOKEN_KEY_PREFIX, ""); // refreshToken UUID döndür
            }
        }
        return null;
    }

    //  Access token geçerli mi kontrol et
    public boolean isAccessTokenValidInRedis(Long userId, String token) {
        String key = ACCESS_TOKEN_KEY_PREFIX + userId;
        String storedToken = redisTemplate.opsForValue().get(key);
        return storedToken != null && storedToken.equals(token);
    }

    //  Access token’a göre refresh token bul
    public String findRefreshTokenByAccessToken(String accessToken) {
        Set<String> keys = redisTemplate.keys(REFRESH_TOKEN_KEY_PREFIX + "*");
        if (keys == null) return null;

        for (String key : keys) {
            String value = redisTemplate.opsForValue().get(key);
            if (value != null && value.endsWith(":" + accessToken)) {
                return key.replace(REFRESH_TOKEN_KEY_PREFIX, "");
            }
        }
        return null;
    }

    //  Refresh token’dan user/domain verisini al
    public String[] getRefreshData(String refreshToken) {
        String value = redisTemplate.opsForValue().get(REFRESH_TOKEN_KEY_PREFIX + refreshToken);
        return value != null ? value.split(":") : null;
    }

    //  Access token süresi dolmuşsa refresh token sayesinde yenile
    public String refreshAccessTokenIfValid(String expiredAccessToken, String role) {
        String refreshToken = findRefreshTokenByAccessToken(expiredAccessToken);
        if (refreshToken == null) return null;

        String[] data = getRefreshData(refreshToken);
        if (data == null || data.length < 3) return null;

        Long userId = Long.parseLong(data[0]);
        Long domainId = Long.parseLong(data[1]);

        // Yeni access token üret
        String newAccessToken = jwtUtil.generateAccessToken(userId, role, domainId);

        // Access token Redis'e kaydet
        saveAccessToken(userId, newAccessToken);

        // Refresh token’ın value’sunu güncelle
        String newValue = userId + ":" + domainId + ":" + newAccessToken;
        redisTemplate.opsForValue().set(REFRESH_TOKEN_KEY_PREFIX + refreshToken, newValue, refreshTokenTtlDays, TimeUnit.DAYS);

        return newAccessToken;
    }

    //  Logout — access token üzerinden tüm kayıtları temizle
    public void logoutByAccessToken(String accessToken) {
        if (accessToken == null || accessToken.isEmpty()) return;

        try {
            Long userId = jwtUtil.extractAllClaims(accessToken).get(JwtUtil.USER_ID, Long.class);

            // Access token sil
            redisTemplate.delete(ACCESS_TOKEN_KEY_PREFIX + userId);

            // Bu access token’a bağlı refresh token’ı sil
            String refreshToken = findRefreshTokenByAccessToken(accessToken);
            if (refreshToken != null) {
                redisTemplate.delete(REFRESH_TOKEN_KEY_PREFIX + refreshToken);
            }

            // Kullanıcıya ait diğer refresh kayıtlarını da sil
            removeAllUserTokensFromRedis(userId);

        } catch (Exception e) {
            String refreshToken = findRefreshTokenByAccessToken(accessToken);
            if (refreshToken != null)
                redisTemplate.delete(REFRESH_TOKEN_KEY_PREFIX + refreshToken);
        }
    }

    //  Kullanıcıya ait tüm refresh kayıtlarını sil
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
