package com.gangofthree.tarladan.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;

import java.util.Arrays;

/**
 * CORS (Cross-Origin Resource Sharing) configuration.
 * * Defines the permissions that let browser-based frontend applications (React, Angular,
 * Vue, etc.), served from a different domain or port, access this backend API.
 */
@Configuration
public class CorsConfig {

    @Bean
    public CorsFilter corsFilter() {
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        CorsConfiguration config = new CorsConfiguration();

        // 1. ALLOW CREDENTIALS
        // This MUST be true for the frontend to send cookies or an 'Authorization'
        // (Bearer token) header. If disabled, the browser blocks requests carrying a
        // token for security reasons.
        config.setAllowCredentials(true);

        // 2. ALLOWED ORIGINS
        // Which addresses (domain/port) can requests come from?
        // We use origin *patterns* instead of setAllowedOrigins("*") because a wildcard
        // is restricted once allowCredentials(true) is set.
        // To simplify requests from mobile apps and work around an Azure-domain issue,
        // all origins are currently allowed via the wildcard pattern.
        config.setAllowedOriginPatterns(Arrays.asList("*"));

        // 3. ALLOWED HEADERS
        // Header types the frontend may send with a request.
        // "*" allows everything (Content-Type, Authorization, X-Requested-With, etc.).
        config.setAllowedHeaders(Arrays.asList("*"));

        // 4. ALLOWED HTTP METHODS
        // Operation types the backend accepts.
        // OPTIONS is required for the browser's CORS "preflight" request.
        config.setAllowedMethods(Arrays.asList(
                "GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"
        ));

        // 5. EXPOSED HEADERS
        // Browsers hide certain response headers from frontend JS by default, for security.
        // These must be explicitly exposed so the frontend (e.g. Axios) can read them.
        config.setExposedHeaders(Arrays.asList(
                "Access-Control-Allow-Origin",
                "Access-Control-Allow-Credentials",
                "Authorization",        // in case the token is also returned in a header
                "X-New-Access-Token",   // JWT refresh — the frontend must read and store this
                "X-Total-Count"         // useful for pagination
        ));

        // 6. PREFLIGHT CACHE DURATION (Max Age)
        // Before every POST/PUT request, the browser first sends an "OPTIONS" preflight
        // request. This setting tells the browser "remember these permissions for 3600
        // seconds (1 hour), don't ask again," reducing unnecessary traffic.
        config.setMaxAge(3600L);

        // 7. PATH SCOPE
        // These rules apply to every endpoint (/**) in the project.
        source.registerCorsConfiguration("/**", config);

        return new CorsFilter(source);
    }
}