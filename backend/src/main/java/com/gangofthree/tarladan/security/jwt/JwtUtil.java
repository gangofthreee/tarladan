package com.gangofthree.tarladan.security.jwt;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.security.Key;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

/**
 * JWT Yardımcı Sınıfı (Token Factory)
 * * Bu sınıf, JSON Web Token (JWT) oluşturma, çözümleme (parsing) ve doğrulama
 * işlemlerinden sorumlu tek yetkili sınıftır.
 * * Veritabanına gitmez, sadece matematiksel ve kriptografik işlemler yapar.
 */
@Component
public class JwtUtil {

    // application.properties dosyasından gizli anahtarı oku.
    // Bu anahtar tokenları imzalamak için kullanılır. Kimseyle paylaşılmamalıdır!
    @Value("${jwt.secret-key}")
    private String SECRET_KEY;

    // Token'ın kaç dakika geçerli olacağı bilgisi.
    @Value("${jwt.access-token-ttl-minutes}")
    private long ACCESS_TOKEN_TTL_MINUTES;

    // JWT Payload anahtarları (kısa isimler kullanarak token boyutunu küçük tutuyoruz)
    public static final String USER_ID = "uid";
    public static final String ROLE = "rol";
    public static final String DOMAIN_ID = "did"; // Role-based ID (farmerId, customerId, vb.)

    /**
     * İmzalama Anahtarını Getir (HMAC-SHA)
     * * application.properties'deki Base64 formatındaki String anahtarı,
     * kriptografik işlemlerde kullanılabilecek gerçek bir 'Key' nesnesine çevirir.
     */
    private Key getSigningKey() {
        byte[] keyBytes;
        try {
            // Önce mevcut anahtarı Base64 olarak çözmeye çalış
            keyBytes = Decoders.BASE64.decode(SECRET_KEY);
        } catch (Exception e) {
            // Eğer Base64 değilse (Örn: Düz metin "my_secret_key_123"), 
            // o zaman bu düz metni Base64'e çevirip öyle kullan.
            // Bu güvenlik için bir "Fallback" meknizmasıdır.
            System.out.println("Warning: Falling back to plain text secret key due to: " + e.getMessage());
            keyBytes = SECRET_KEY.getBytes();
        }
        return Keys.hmacShaKeyFor(keyBytes);
    }

    /**
     * Token'ın İçini Oku (Claims Extraction)
     * * Şifrelenmiş token'ı alır, imzasını doğrular ve içindeki verileri (Claims) çıkarır.
     * * Eğer imza geçersizse veya token bozulmuşsa Exception fırlatır.
     * * @param token JWT Access Token
     * @return Claims (Token içindeki userId, role vb. bilgiler)
     */
    public Claims extractAllClaims(String token) {
        try {
            return Jwts
                    .parserBuilder()
                    .setSigningKey(getSigningKey()) // İmzayı doğrula
                    .build()
                    .parseClaimsJws(token)
                    .getBody();
        } catch (ExpiredJwtException e) {
            // Token süresi dolmuş olsa bile içindeki bilgileri (Claims) almak isteyebiliriz.
            // Örneğin: "Refresh Token" işlemi yaparken kullanıcının kim olduğunu öğrenmek için.
            return e.getClaims();
        } catch (Exception e) {
            // Geçersiz imza veya değiştirilmiş token
            throw new IllegalArgumentException("Invalid JWT: " + e.getMessage());
        }
    }

    /**
     * Yeni Access Token Üret (Create Token)
     * * Kullanıcı giriş yaptığında veya token yenilendiğinde çağrılır.
     * * @param userId Kullanıcının ana tablodaki ID'si (Users tablosu)
     * @param role Kullanıcının rolü (FARMER, CUSTOMER vb.)
     * @param domainId Kullanıcının rolüne özgü ID'si (Farmers veya Customers tablosu)
     * @return String formatında imzalanmış JWT (eyGbHbGci...)
     */
    public String generateAccessToken(Long userId, String role, Long domainId) {
        Map<String, Object> claims = new HashMap<>();
        claims.put(USER_ID, userId);
        claims.put(ROLE, role);
        claims.put(DOMAIN_ID, domainId); // Domain ID'sini payload'a ekliyoruz

        return Jwts
                .builder()
                .setClaims(claims)
                .setSubject(userId.toString()) // Standart 'sub' alanı
                .setIssuedAt(new Date(System.currentTimeMillis())) // Oluşturulma tarihi ('iat')
                .setExpiration(new Date(System.currentTimeMillis() + ACCESS_TOKEN_TTL_MINUTES * 60 * 1000)) // Bitiş tarihi ('exp')
                .signWith(getSigningKey(), SignatureAlgorithm.HS256) // İmzala
                .compact();
    }

    /**
     * Token Süresi Doldu mu? (Expiration Check)
     * * Bu metot, JwtAuthFilter içinde "Acaba bu tokenın süresi geçmiş mi?" kontrolü
     * yapmak için kullanılır. Süresi geçmişse true döner.
     */
    public boolean isTokenExpired(String token) {
        try {
            // Token'ı parse etmeye çalış. Eğer süresi dolmuşsa kütüphane otomatik olarak
            // ExpiredJwtException fırlatır.
            Jwts.parserBuilder().setSigningKey(getSigningKey()).build().parseClaimsJws(token);
            return false; // Hata yoksa süre dolmamıştır.
        } catch (ExpiredJwtException e) {
            return true; // Süresi dolmuş!
        } catch (Exception e) {
            // Token bozuksa veya imza yanlışsa da "geçersiz" sayalım.
            return true;
        }
    }

    /**
     * Token İçinden Domain ID'yi Çıkar
     * * Controller katmanında veya filtrelerde "Bu isteği yapan Çiftçinin ID'si ne?"
     * sorusunun cevabını verir.
     */
    public Long extractDomainId(String token) {
        Claims claims = extractAllClaims(token);
        Object domainId = claims.get(DOMAIN_ID);

        if (domainId == null) {
            throw new IllegalArgumentException("Token içinde domainId (did) bulunamadı. Token eksik bilgi içeriyor.");
        }

        return Long.parseLong(domainId.toString());
    }
}