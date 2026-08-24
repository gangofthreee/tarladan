package com.gangofthree.tarladan.security.jwt;

import com.gangofthree.tarladan.security.service.TokenService;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.MalformedJwtException;
import io.jsonwebtoken.UnsupportedJwtException;
import io.jsonwebtoken.security.SignatureException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Collections;
import java.util.List;

/**
 * JWT authentication filter (the gatekeeper).
 * * This class intercepts EVERY HTTP request reaching the server (login/register excluded).
 * * Its job: check whether the caller's token ("passport") is valid.
 * * OncePerRequestFilter guarantees it runs exactly once per request.
 */
@Component
public class JwtAuthFilter extends OncePerRequestFilter {

    private final JwtUtil jwtUtil;
    private final TokenService tokenService;

    public JwtAuthFilter(JwtUtil jwtUtil, TokenService tokenService) {
        this.jwtUtil = jwtUtil;
        this.tokenService = tokenService;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {

        // 1. HEADER CHECK
        // Is there an "Authorization" header, and does it start with "Bearer "?
        final String authHeader = request.getHeader("Authorization");
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            // No token: continue the filter chain (SecurityConfig's .permitAll() rules apply).
            // If the target is a protected endpoint, SecurityConfig will already return 403.
            filterChain.doFilter(request, response);
            return;
        }

        // Strip the "Bearer " prefix (first 7 characters) to get the raw token.
        final String jwt = authHeader.substring(7);
        Long userId = null;
        String role = null;
        Long domainId = null;

        try {
            // 2. TOKEN PARSING
            // Read the claims embedded in the token.
            // Throws an exception if the token is forged or its signature is invalid.
            Claims claims = jwtUtil.extractAllClaims(jwt);
            userId = claims.get(JwtUtil.USER_ID, Long.class);
            role = claims.get(JwtUtil.ROLE, String.class);
            domainId = claims.get(JwtUtil.DOMAIN_ID, Long.class);

            // 3. EXPIRED TOKEN HANDLING (auto-refresh logic)
            // Has the token expired?
            if (jwtUtil.isTokenExpired(jwt)) {
                // The access token is expired, but the user may still have a valid session
                // (a refresh token in Redis). Ask TokenService for a new access token in
                // exchange for this expired one.
                String newAccessToken = tokenService.refreshAccessTokenIfValid(jwt, role);

                if (newAccessToken != null) {
                    // Refresh succeeded!
                    // Return the new token via a response header so the frontend can pick it up.
                    response.setHeader("X-New-Access-Token", newAccessToken);

                    // Authenticate the user for this request.
                    authenticateUser(request, userId, role, domainId);

                    // Continue processing the request.
                    filterChain.doFilter(request, response);
                    return;
                }

                // Refresh failed (the refresh token has also expired, or the user logged out).
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write("Session expired, please login again");
                return;
            }

            // 4. REDIS CHECK (whitelist)
            // The token's format and expiry are fine, but has the user logged out?
            // Check whether this token is still on the "active" list in Redis.
            if (!tokenService.isAccessTokenValidInRedis(userId, jwt)) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write("Access Token Revoked or Replaced (Logout detected)");
                return;
            }

            // 5. AUTHENTICATION
            // If the security context is empty (the user isn't recognized yet), authenticate them.
            if (userId != null && role != null && SecurityContextHolder.getContext().getAuthentication() == null) {
                authenticateUser(request, userId, role, domainId);
            }

        } catch (ExpiredJwtException e) {
            // Token expired and could not be refreshed.
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("Access Token Expired");
            return;
        } catch (SignatureException | MalformedJwtException | UnsupportedJwtException e) {
            // Token is forged, corrupted, or was tampered with.
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.getWriter().write("Invalid JWT Signature or Structure");
            return;
        } catch (IllegalArgumentException e) {
            // Token is empty or otherwise malformed.
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Bad Request: " + e.getMessage());
            return;
        }

        // Everything checks out: forward the request to the Controller.
        filterChain.doFilter(request, response);
    }

    /**
     * Helper: registers the user in the Spring Security context.
     */
    private void authenticateUser(HttpServletRequest request, Long userId, String role, Long domainId) {
        // Build the authority (e.g. ROLE_FARMER).
        List<SimpleGrantedAuthority> authorities =
                Collections.singletonList(new SimpleGrantedAuthority("ROLE_" + role));

        // Build the authentication token.
        UsernamePasswordAuthenticationToken authToken =
                new UsernamePasswordAuthenticationToken(userId, null, authorities);

        // Attach request details (IP address, session id, etc.).
        authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));

        // Register the authenticated user.
        SecurityContextHolder.getContext().setAuthentication(authToken);

        // Expose domainId (farmerId, truckerId, ...) as a request attribute so controllers
        // can easily answer "which farmer/trucker is performing this action?".
        request.setAttribute("domainId", domainId);
        request.setAttribute("uid", userId);
    }
}