package com.gangofthree.tarladan.core.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    private final JwtAuthFilter jwtAuthFilter;

    // JwtAuthFilter'ı constructor ile inject ediyoruz
    public SecurityConfig(JwtAuthFilter jwtAuthFilter) {
        this.jwtAuthFilter = jwtAuthFilter;
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                // 1. CSRF korumasını devre dışı bırakır (JWT için uygundur).
                .csrf(AbstractHttpConfigurer::disable)

                // CORS'u etkinleştir
                .cors(cors -> cors.configure(http))

                // 2. HTTP Basic ve Form tabanlı kimlik doğrulamasını devre dışı bırakır.
                .formLogin(AbstractHttpConfigurer::disable)
                .httpBasic(AbstractHttpConfigurer::disable)

                // 3. Varsayılan kullanıcı servislerini devre dışı bırakır.
                .userDetailsService(username -> null)

                // 4. Oturum Yönetimini Stateless olarak ayarlar.
                .sessionManagement(session -> session
                        .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
                )

                // 5. Yetkilendirme Kuralları:
                .authorizeHttpRequests(auth -> auth
                        // Public Endpoints: Kayıt, Giriş, Token Yenileme
                        .requestMatchers("/api/users/register", "/api/users/login", "/api/users/refresh", "/api/verification/**").permitAll()

                        // Örnek Rol Bazlı Korumalı Endpointler
                        // NOT: /modules/farmer altındaki endpointler için FARMER rolü gerekli
                        .requestMatchers("/farmer/**").hasRole("FARMER")
                        .requestMatchers("/product/**").hasRole("FARMER")

                        .requestMatchers("/customer/**").hasRole("CUSTOMER")
                        .requestMatchers("/order/**").hasRole("CUSTOMER")

                        .requestMatchers("/trucker/**").hasRole("TRUCKER")
                        .requestMatchers("/truck/**").hasRole("TRUCKER")
                        .requestMatchers("/truckAd/**").hasRole("TRUCKER")

                        .requestMatchers("/depot-owner/**").hasRole("DEPOT_OWNER")
                        .requestMatchers("/depot/**").hasRole("DEPOT_OWNER")

                        // Kalan tüm istekler kimlik doğrulaması gerektirir
                        .anyRequest().authenticated()
                )

                // 6. JWT filtresini UsernamePasswordAuthenticationFilter'dan önce ekler.
                .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}