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
 * JWT Kimlik Doğrulama Filtresi (The Gatekeeper)
 * * Bu sınıf, sunucuya gelen HER HTTP isteğini (Login/Register hariç) karşılar.
 * * Görevi: "Gelen kişinin elindeki Token (Pasaport) geçerli mi?" kontrolünü yapmaktır.
 * * OncePerRequestFilter: Bir istek için sadece bir kez çalışacağını garanti eder.
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

        // 1. HEADER KONTROLÜ
        // İstek başlığında "Authorization" var mı ve "Bearer " ile başlıyor mu?
        final String authHeader = request.getHeader("Authorization");
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            // Token yoksa, filtre zincirine devam et (SecurityConfig'deki .permitAll() kuralları devreye girer)
            // Eğer korumalı bir sayfaya gidiyorsa SecurityConfig zaten 403 verecektir.
            filterChain.doFilter(request, response);
            return;
        }

        // "Bearer " kısmını (ilk 7 karakter) atıp saf token'ı alıyoruz.
        final String jwt = authHeader.substring(7);
        Long userId = null;
        String role = null;
        Long domainId = null;

        try {
            // 2. TOKEN ÇÖZÜMLEME (Parsing)
            // Token içindeki bilgileri (Claims) okuyoruz.
            // Eğer token sahte ise veya imzası bozuksa burada Exception fırlatır.
            Claims claims = jwtUtil.extractAllClaims(jwt);
            userId = claims.get(JwtUtil.USER_ID, Long.class);
            role = claims.get(JwtUtil.ROLE, String.class);
            domainId = claims.get(JwtUtil.DOMAIN_ID, Long.class);

            // 3. SÜRESİ DOLMUŞ TOKEN YÖNETİMİ (Auto-Refresh Logic)
            // Token'ın süresi dolmuş mu?
            if (jwtUtil.isTokenExpired(jwt)) {
                // Token bitmiş ama kullanıcının hala geçerli bir oturumu (Redis'te Refresh Token) olabilir.
                // TokenService'e gidip "Bu eski token karşılığında bana yenisini ver" diyoruz.
                String newAccessToken = tokenService.refreshAccessTokenIfValid(jwt, role);

                if (newAccessToken != null) {
                    // YENİLEME BAŞARILI!
                    // Yeni token'ı Response Header'a ekliyoruz ki Frontend bunu alıp güncellesin.
                    response.setHeader("X-New-Access-Token", newAccessToken);

                    // Kullanıcıyı sisteme giriş yapmış sayıyoruz (Authentication).
                    authenticateUser(request, userId, role, domainId);

                    // İsteği işlemeye devam et
                    filterChain.doFilter(request, response);
                    return;
                }

                // Yenileme başarısız (Refresh token da bitmiş veya logout olmuş).
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write("Session expired, please login again");
                return;
            }

            // 4. REDIS KONTROLÜ (Whitelist / Blacklist)
            // Token formatı doğru ve süresi var. AMA kullanıcı "Çıkış Yap" demiş olabilir mi?
            // Redis'te bu token hala "aktif" listesinde mi diye bakıyoruz.
            if (!tokenService.isAccessTokenValidInRedis(userId, jwt)) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write("Access Token Revoked or Replaced (Logout detected)");
                return;
            }

            // 5. KİMLİK DOĞRULAMA (Authentication)
            // Security Context boşsa (yani kullanıcı henüz tanınmamışsa) sisteme tanıtıyoruz.
            if (userId != null && role != null && SecurityContextHolder.getContext().getAuthentication() == null) {
                authenticateUser(request, userId, role, domainId);
            }

        } catch (ExpiredJwtException e) {
            // Token süresi dolmuş ve Refresh edilememişse
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("Access Token Expired");
            return;
        } catch (SignatureException | MalformedJwtException | UnsupportedJwtException e) {
            // Token sahte, bozuk veya değiştirilmiş
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.getWriter().write("Invalid JWT Signature or Structure");
            return;
        } catch (IllegalArgumentException e) {
            // Token boş veya hatalı argüman
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Bad Request: " + e.getMessage());
            return;
        }

        // Her şey yolundaysa, isteği Controller'a ilet.
        filterChain.doFilter(request, response);
    }

    /**
     * Yardımcı Metot: Kullanıcıyı Spring Security Context'ine kaydeder.
     */
    private void authenticateUser(HttpServletRequest request, Long userId, String role, Long domainId) {
        // Rolü ayarla (ROLE_FARMER gibi)
        List<SimpleGrantedAuthority> authorities =
                Collections.singletonList(new SimpleGrantedAuthority("ROLE_" + role));

        // Kimlik kartını oluştur
        UsernamePasswordAuthenticationToken authToken =
                new UsernamePasswordAuthenticationToken(userId, null, authorities);

        // Request detaylarını ekle (IP adresi, Session ID vb.)
        authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));

        // SİSTEME GİRİŞ YAPTIR
        SecurityContextHolder.getContext().setAuthentication(authToken);

        // Controller'larda "Hangi çiftçi işlem yapıyor?" diye kolayca bulmak için
        // domainId'yi (farmerId, truckerId) request attribute'una ekliyoruz.
        request.setAttribute("domainId", domainId);
    }
}