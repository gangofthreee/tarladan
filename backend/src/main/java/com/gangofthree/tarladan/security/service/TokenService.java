package com.gangofthree.tarladan.security.service;

import com.gangofthree.tarladan.security.jwt.JwtUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.util.Set;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

/**
 * Token management service (Redis-backed).
 * * This class manages the lifecycle of JWTs (access and refresh) in Redis.
 * * A JWT is normally stateless, but we store tokens in Redis (a whitelist approach)
 * so we can support "logout" and "secure refresh" semantics.
 */
@Service
public class TokenService {

    private static final Logger log = LoggerFactory.getLogger(TokenService.class);

    private final StringRedisTemplate redisTemplate;
    private final JwtUtil jwtUtil;

    // Access token lifetime (e.g. 15 min)
    @Value("${jwt.access-token-ttl-minutes}")
    private long accessTokenTtlMinutes;

    // Refresh token lifetime (e.g. 7 days)
    @Value("${jwt.refresh-token-ttl-days}")
    private long refreshTokenTtlDays;

    // Redis key prefixes.
    // Access tokens are stored as "access:123" (userId).
    private static final String ACCESS_TOKEN_KEY_PREFIX = "access:";
    // Refresh tokens are stored as "refresh:uuid-string".
    private static final String REFRESH_TOKEN_KEY_PREFIX = "refresh:";

    public TokenService(StringRedisTemplate redisTemplate, JwtUtil jwtUtil) {
        this.redisTemplate = redisTemplate;
        this.jwtUtil = jwtUtil;
    }

    /**
     * Save the access token to Redis (whitelist).
     * * Called when the user logs in or a token is refreshed.
     * * We write the token to Redis. JwtAuthFilter looks it up on every request;
     * if the token isn't in Redis (expired or deleted), the request is rejected.
     */
    public void saveAccessToken(Long userId, String accessToken) {
        String key = ACCESS_TOKEN_KEY_PREFIX + userId;
        // Store the token keyed by the user's id, with a TTL.
        redisTemplate.opsForValue().set(key, accessToken, accessTokenTtlMinutes, TimeUnit.MINUTES);
    }

    /**
     * Create or update the refresh token (session management).
     * * The access token is short-lived (15-30 min). The refresh token is long-lived (7-30 days).
     * * Once the access token expires, the refresh token lets the user obtain a new one
     * without re-entering their password.
     */
    public String createOrUpdateRefreshToken(Long userId, Long domainId, String accessToken) {
        // 1. Check whether this user already has an active session (refresh token).
        String existingRefreshToken = findRefreshTokenByUserId(userId);

        String refreshToken;
        if (existingRefreshToken != null) {
            // 2. Update the existing session (rotation/extension).
            // The refresh token id (UUID) stays the same, but the access token it points
            // to is updated, extending the user's session.
            refreshToken = existingRefreshToken;

            // Format: "userId:domainId:accessToken"
            String newValue = userId + ":" + domainId + ":" + accessToken;

            redisTemplate.opsForValue().set(REFRESH_TOKEN_KEY_PREFIX + refreshToken, newValue, refreshTokenTtlDays, TimeUnit.DAYS);
        } else {
            // 3. First-time login: generate a new refresh token.
            refreshToken = UUID.randomUUID().toString();
            String value = userId + ":" + domainId + ":" + accessToken;
            redisTemplate.opsForValue().set(REFRESH_TOKEN_KEY_PREFIX + refreshToken, value, refreshTokenTtlDays, TimeUnit.DAYS);
        }

        return refreshToken;
    }

    /**
     * Find the refresh token belonging to a given user id.
     * * NOTE: Redis's 'keys' command can hurt performance (O(N)). In production, with
     * thousands of users, 'SCAN' or a Set-based index would be preferable.
     * Acceptable for now during development.
     */
    private String findRefreshTokenByUserId(Long userId) {
        // Fetch all keys starting with "refresh:" (an expensive operation!).
        Set<String> keys = redisTemplate.keys(REFRESH_TOKEN_KEY_PREFIX + "*");
        if (keys == null) return null;

        // Walk all keys and check whether the value starts with "userId:".
        for (String key : keys) {
            String value = redisTemplate.opsForValue().get(key);
            if (value != null && value.startsWith(userId + ":")) {
                // Found it: return the UUID without the "refresh:" prefix.
                return key.replace(REFRESH_TOKEN_KEY_PREFIX, "");
            }
        }
        return null;
    }

    /**
     * Access token validity check (the gatekeeper check).
     * * Called by JwtAuthFilter.
     * * Does the incoming token match the one stored in Redis exactly?
     * * If the user has logged out, the Redis entry is gone and this method returns false.
     */
    public boolean isAccessTokenValidInRedis(Long userId, String token) {
        String key = ACCESS_TOKEN_KEY_PREFIX + userId;
        String storedToken = redisTemplate.opsForValue().get(key);
        // Does a token exist AND does it match the incoming one?
        return storedToken != null && storedToken.equals(token);
    }

    /**
     * Find the refresh token corresponding to an access token.
     * * Used during token refresh to determine which session the expired access token belongs to.
     */
    public String findRefreshTokenByAccessToken(String accessToken) {
        Set<String> keys = redisTemplate.keys(REFRESH_TOKEN_KEY_PREFIX + "*");
        if (keys == null) return null;

        for (String key : keys) {
            String value = redisTemplate.opsForValue().get(key);
            // Value format: "userId:domainId:accessToken"
            // Does it end with our access token?
            if (value != null && value.endsWith(":" + accessToken)) {
                return key.replace(REFRESH_TOKEN_KEY_PREFIX, "");
            }
        }
        return null;
    }

    /**
     * Helper: parse a refresh token's stored value.
     * @return array of [userId, domainId, accessToken]
     */
    public String[] getRefreshData(String refreshToken) {
        String value = redisTemplate.opsForValue().get(REFRESH_TOKEN_KEY_PREFIX + refreshToken);
        return value != null ? value.split(":") : null;
    }

    /**
     * Silent refresh logic.
     * * When the user's access token has expired (caught by JwtAuthFilter), this method
     * checks the refresh token.
     * * If the refresh token is still valid, a new access token is issued transparently.
     */
    public String refreshAccessTokenIfValid(String expiredAccessToken, String role) {
        // 1. Is there a refresh token associated with this expired access token?
        String refreshToken = findRefreshTokenByAccessToken(expiredAccessToken);
        if (refreshToken == null) return null; // No session left; the user must log in again.

        // 2. Decode the refresh token's stored data.
        String[] data = getRefreshData(refreshToken);
        if (data == null || data.length < 3) return null;

        Long userId = Long.parseLong(data[0]);
        Long domainId = Long.parseLong(data[1]);

        // 3. Issue a new access token.
        String newAccessToken = jwtUtil.generateAccessToken(userId, role, domainId);

        // 4. Update Redis (the old access token is replaced with the new one).
        saveAccessToken(userId, newAccessToken);

        // 5. Also update the access token embedded in the refresh token's value.
        String newValue = userId + ":" + domainId + ":" + newAccessToken;
        redisTemplate.opsForValue().set(REFRESH_TOKEN_KEY_PREFIX + refreshToken, newValue, refreshTokenTtlDays, TimeUnit.DAYS);

        return newAccessToken;
    }

    /**
     * Logout.
     * * When the user logs out, both the access and refresh tokens are deleted from Redis.
     * * Even though those tokens may still look valid (the JWT itself hasn't expired),
     * * JwtAuthFilter rejects them because they're no longer present in Redis.
     */
    public void logoutByAccessToken(String accessToken) {
        if (accessToken == null || accessToken.isEmpty()) return;

        try {
            Long userId = jwtUtil.extractAllClaims(accessToken).get(JwtUtil.USER_ID, Long.class);

            // Delete the access token (remove it from the whitelist).
            redisTemplate.delete(ACCESS_TOKEN_KEY_PREFIX + userId);

            // Also find and delete the refresh token tied to this access token.
            String refreshToken = findRefreshTokenByAccessToken(accessToken);
            if (refreshToken != null) {
                redisTemplate.delete(REFRESH_TOKEN_KEY_PREFIX + refreshToken);
            }

            // Clean up any remaining tokens belonging to this user, just in case.
            removeAllUserTokensFromRedis(userId);

        } catch (Exception e) {
            // Even if the token itself can't be parsed, still try to clean up Redis.
            log.warn("Failed to parse access token during logout, falling back to lookup-by-token cleanup: {}", e.getMessage());
            String refreshToken = findRefreshTokenByAccessToken(accessToken);
            if (refreshToken != null)
                redisTemplate.delete(REFRESH_TOKEN_KEY_PREFIX + refreshToken);
        }
    }

    /**
     * Cleanup helper.
     * * Deletes every refresh token that may belong to a given user.
     * * Can be used for a "log out from all devices" feature.
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