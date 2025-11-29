package com.gangofthree.tarladan.core.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
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
                .csrf(AbstractHttpConfigurer::disable)
                .cors(cors -> cors.configure(http))
                .formLogin(AbstractHttpConfigurer::disable)
                .httpBasic(AbstractHttpConfigurer::disable)
                .userDetailsService(username -> null)
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth
                        // SWAGGER IZINLERI (Burasi artik calisacak)
                        .requestMatchers(
                                "/v3/api-docs/**",
                                "/swagger-ui/**",
                                "/swagger-ui.html"
                        ).permitAll()

                        // PUBLIC ENDPOINTLER
                        .requestMatchers(
                                "/api/users/register",
                                "/api/users/login",
                                "/api/users/refresh",
                                "/api/verification/**",
                                "/google/auth",
                                "/google/verify-status",
                                "/auth/password-reset",
                                "/auth/password-reset/set-password",
                                "/auth/password-reset/confirm-code"
                        ).permitAll()

                        // ROL BAZLI ENDPOINTLER (Aynen korundu)
                        .requestMatchers(HttpMethod.GET, "/farmer/**").hasAnyRole("FARMER", "CUSTOMER")
                        .requestMatchers(HttpMethod.POST, "/farmer/**").hasRole("FARMER")
                        .requestMatchers(HttpMethod.PUT, "/farmer/**").hasRole("FARMER")
                        .requestMatchers(HttpMethod.DELETE, "/farmer/**").hasRole("FARMER")

                        .requestMatchers(HttpMethod.GET, "/product/**").hasAnyRole("FARMER", "CUSTOMER")
                        .requestMatchers(HttpMethod.POST, "/product/**").hasRole("FARMER")
                        .requestMatchers(HttpMethod.PUT, "/product/**").hasRole("FARMER")
                        .requestMatchers(HttpMethod.DELETE, "/product/**").hasRole("FARMER")

                        .requestMatchers("/customer/**").hasRole("CUSTOMER")
                        .requestMatchers("/order/**").hasRole("CUSTOMER")

                        .requestMatchers(HttpMethod.GET, "/truck/**").hasAnyRole("TRUCKER", "CUSTOMER")
                        .requestMatchers(HttpMethod.POST, "/truck/**").hasRole("TRUCKER")
                        .requestMatchers(HttpMethod.PUT, "/truck/**").hasRole("TRUCKER")
                        .requestMatchers(HttpMethod.DELETE, "/truck/**").hasRole("TRUCKER")

                        .requestMatchers(HttpMethod.GET, "/truckAd/**").hasAnyRole("TRUCKER", "CUSTOMER")
                        .requestMatchers(HttpMethod.POST, "/truckAd/**").hasRole("TRUCKER")
                        .requestMatchers(HttpMethod.PUT, "/truckAd/**").hasRole("TRUCKER")
                        .requestMatchers(HttpMethod.DELETE, "/truckAd/**").hasRole("TRUCKER")

                        .requestMatchers(HttpMethod.GET, "/depot/**").hasAnyRole("DEPOT_OWNER", "FARMER", "CUSTOMER")
                        .requestMatchers(HttpMethod.POST, "/depot/**").hasRole("DEPOT_OWNER")
                        .requestMatchers(HttpMethod.PUT, "/depot/**").hasRole("DEPOT_OWNER")
                        .requestMatchers(HttpMethod.DELETE, "/depot/**").hasRole("DEPOT_OWNER")

                        .anyRequest().authenticated()
                )
                .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}