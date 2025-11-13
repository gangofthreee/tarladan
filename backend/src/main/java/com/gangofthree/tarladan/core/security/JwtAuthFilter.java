package com.gangofthree.tarladan.core.security;

import com.gangofthree.tarladan.common.utils.JwtUtil;
import com.gangofthree.tarladan.core.service.TokenService;
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

        final String authHeader = request.getHeader("Authorization");
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }

        final String jwt = authHeader.substring(7);
        Long userId = null;
        String role = null;
        Long domainId = null; // ✅ domainId (truckerId, farmerId vb.)

        try {
            Claims claims = jwtUtil.extractAllClaims(jwt);
            userId = claims.get(JwtUtil.USER_ID, Long.class);
            role = claims.get(JwtUtil.ROLE, String.class);
            domainId = claims.get(JwtUtil.DOMAIN_ID, Long.class); // JWT payload’ta domainId olmalı

            // Access token expired mı?
            if (jwtUtil.isTokenExpired(jwt)) {
                String newAccessToken = tokenService.refreshAccessTokenIfValid(jwt, role);
                if (newAccessToken != null) {
                    response.setHeader("X-New-Access-Token", newAccessToken);

                    List<SimpleGrantedAuthority> authorities =
                            Collections.singletonList(new SimpleGrantedAuthority("ROLE_" + role));

                    UsernamePasswordAuthenticationToken authToken =
                            new UsernamePasswordAuthenticationToken(userId, null, authorities);

                    authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                    SecurityContextHolder.getContext().setAuthentication(authToken);

                    // DomainId’yi request attribute olarak set et
                    request.setAttribute("domainId", domainId);

                    filterChain.doFilter(request, response);
                    return;
                }

                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write("Session expired, please login again");
                return;
            }

            // Token Redis'te aktif mi?
            if (!tokenService.isAccessTokenValidInRedis(userId, jwt)) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write("Access Token Revoked or Replaced");
                return;
            }

            // Security Context oluştur
            if (userId != null && role != null && SecurityContextHolder.getContext().getAuthentication() == null) {
                List<SimpleGrantedAuthority> authorities =
                        Collections.singletonList(new SimpleGrantedAuthority("ROLE_" + role));

                UsernamePasswordAuthenticationToken authToken =
                        new UsernamePasswordAuthenticationToken(userId, null, authorities);

                authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                SecurityContextHolder.getContext().setAuthentication(authToken);

                // ✅ DomainId’yi request attribute olarak set et
                request.setAttribute("domainId", domainId);
            }

        } catch (ExpiredJwtException e) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("Access Token Expired");
            return;
        } catch (SignatureException | MalformedJwtException | UnsupportedJwtException e) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.getWriter().write("Invalid JWT Signature or Structure");
            return;
        } catch (IllegalArgumentException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Bad Request: " + e.getMessage());
            return;
        }

        filterChain.doFilter(request, response);
    }
}
