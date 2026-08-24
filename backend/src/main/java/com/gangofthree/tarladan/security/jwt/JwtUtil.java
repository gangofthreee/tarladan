package com.gangofthree.tarladan.security.jwt;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.security.Key;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

/**
 * JWT helper class (token factory).
 * * This is the single class responsible for creating, parsing, and validating
 * JSON Web Tokens (JWTs).
 * * It never talks to the database — only cryptographic and mathematical operations.
 */
@Component
public class JwtUtil {

    private static final Logger log = LoggerFactory.getLogger(JwtUtil.class);

    // Read the secret key from application.properties.
    // This key signs the tokens and must never be shared.
    @Value("${jwt.secret-key}")
    private String SECRET_KEY;

    // How many minutes an access token is valid for.
    @Value("${jwt.access-token-ttl-minutes}")
    private long ACCESS_TOKEN_TTL_MINUTES;

    // JWT payload claim keys (kept short to minimize token size).
    public static final String USER_ID = "uid";
    public static final String ROLE = "rol";
    public static final String DOMAIN_ID = "did"; // Role-based id (farmerId, customerId, etc.)

    /**
     * Build the signing key (HMAC-SHA).
     * * Converts the Base64-encoded string from application.properties into an
     * actual 'Key' object usable for cryptographic operations.
     */
    private Key getSigningKey() {
        byte[] keyBytes;
        try {
            // First, try to decode the configured key as Base64.
            keyBytes = Decoders.BASE64.decode(SECRET_KEY);
        } catch (Exception e) {
            // If it isn't valid Base64 (e.g. a plain string like "my_secret_key_123"),
            // fall back to using the raw bytes of that plain text.
            log.warn("Falling back to plain-text secret key, could not Base64-decode jwt.secret-key: {}", e.getMessage());
            keyBytes = SECRET_KEY.getBytes();
        }
        return Keys.hmacShaKeyFor(keyBytes);
    }

    /**
     * Extract all claims from a token.
     * * Parses the token, verifies its signature, and returns the embedded claims.
     * * Throws if the signature is invalid or the token is malformed.
     * @param token JWT access token
     * @return the claims embedded in the token (userId, role, etc.)
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
            // Even for an expired token, the claims are still useful — e.g. the refresh-token
            // flow needs to know who the token belonged to.
            return e.getClaims();
        }
        // Other exceptions (SignatureException, MalformedJwtException, UnsupportedJwtException,
        // IllegalArgumentException) are intentionally left to propagate to the caller
        // (JwtAuthFilter), which maps each one to a specific HTTP response. Wrapping them all
        // into a single generic exception here would make those distinct cases unreachable.
    }

    /**
     * Generate a new access token.
     * * Called on login or when a token is refreshed.
     * @param userId the user's id in the main Users table
     * @param role the user's role (FARMER, CUSTOMER, etc.)
     * @param domainId the user's role-specific id (in the Farmers or Customers table)
     * @return a signed JWT string (eyJhbGci...)
     */
    public String generateAccessToken(Long userId, String role, Long domainId) {
        Map<String, Object> claims = new HashMap<>();
        claims.put(USER_ID, userId);
        claims.put(ROLE, role);
        claims.put(DOMAIN_ID, domainId);

        return Jwts
                .builder()
                .setClaims(claims)
                .setSubject(userId.toString()) // standard 'sub' claim
                .setIssuedAt(new Date(System.currentTimeMillis())) // 'iat'
                .setExpiration(new Date(System.currentTimeMillis() + ACCESS_TOKEN_TTL_MINUTES * 60 * 1000)) // 'exp'
                .signWith(getSigningKey(), SignatureAlgorithm.HS256)
                .compact();
    }

    /**
     * Has the token expired?
     * * Used by JwtAuthFilter to check whether a token's validity window has passed.
     * Returns true if it has.
     */
    public boolean isTokenExpired(String token) {
        try {
            // Try to parse the token. The library throws ExpiredJwtException automatically
            // if it has expired.
            Jwts.parserBuilder().setSigningKey(getSigningKey()).build().parseClaimsJws(token);
            return false; // No error: not expired.
        } catch (ExpiredJwtException e) {
            return true; // Expired!
        } catch (Exception e) {
            // Treat a malformed or incorrectly signed token as "expired" too, so the caller
            // rejects it the same way.
            return true;
        }
    }

    /**
     * Extract the domain id from a token.
     * * Answers "which farmer/trucker/etc. is making this request?" for controllers and filters.
     */
    public Long extractDomainId(String token) {
        Claims claims = extractAllClaims(token);
        Object domainId = claims.get(DOMAIN_ID);

        if (domainId == null) {
            throw new IllegalArgumentException("Token does not contain a domainId (did) claim.");
        }

        return Long.parseLong(domainId.toString());
    }
}
