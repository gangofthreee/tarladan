package com.gangofthree.tarladan.common.utils;

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
import java.util.function.Function;

@Component
public class JwtUtil {

    @Value("${jwt.secret-key}")
    private String SECRET_KEY;

    @Value("${jwt.access-token-ttl-minutes}")
    private long ACCESS_TOKEN_TTL_MINUTES;

    // JWT Paylaod anahtarları (kısa isimler önerilir)
    public static final String USER_ID = "uid";
    public static final String ROLE = "rol";
    public static final String DOMAIN_ID = "did"; // Role-based ID (farmerId, customerId, vb.)

    private Key getSigningKey() {
        byte[] keyBytes = Decoders.BASE64.decode(SECRET_KEY);
        return Keys.hmacShaKeyFor(keyBytes);
    }

    /**
     * Access Token içerisindeki tüm claim'leri çıkarır.
     * @param token JWT Access Token
     * @return Claims objesi
     */
    public Claims extractAllClaims(String token) {
        try {
            return Jwts
                    .parserBuilder()
                    .setSigningKey(getSigningKey())
                    .build()
                    .parseClaimsJws(token)
                    .getBody();
        } catch (ExpiredJwtException e) {
            // Token süresi dolmuş olsa bile claim'leri döndür (refresh için gerekli olabilir)
            return e.getClaims();
        } catch (Exception e) {
            // Geçersiz imza veya diğer JWT hataları
            throw new IllegalArgumentException("Invalid JWT: " + e.getMessage());
        }
    }

    /**
     * Yeni bir Access Token üretir.
     */
    public String generateAccessToken(Long userId, String role, Long domainId) {
        Map<String, Object> claims = new HashMap<>();
        claims.put(USER_ID, userId);
        claims.put(ROLE, role);
        claims.put(DOMAIN_ID, domainId); // Domain ID'sini payload'a ekliyoruz

        return Jwts
                .builder()
                .setClaims(claims)
                .setSubject(userId.toString())
                .setIssuedAt(new Date(System.currentTimeMillis()))
                .setExpiration(new Date(System.currentTimeMillis() + ACCESS_TOKEN_TTL_MINUTES * 60 * 1000))
                .signWith(getSigningKey(), SignatureAlgorithm.HS256)
                .compact();
    }

    /**
     * Token'ın sadece süresinin dolup dolmadığını kontrol eder.
     */
    public boolean isTokenExpired(String token) {
        try {
            // Token'ın geçerli olup olmadığını kontrol eder. Süresi dolmuşsa istisna fırlatır.
            Jwts.parserBuilder().setSigningKey(getSigningKey()).build().parseClaimsJws(token);
            return false;
        } catch (ExpiredJwtException e) {
            return true; // Süresi dolmuş
        } catch (Exception e) {
            // Geçersiz token (imza hatası vb.)
            return true;
        }
    }
}
