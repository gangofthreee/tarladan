package com.gangofthree.tarladan.config;

import com.gangofthree.tarladan.security.jwt.JwtAuthFilter;
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

/**
 * Main Spring Security configuration.
 * * This class is the application's firewall. It determines how HTTP requests are
 * filtered, who can access what, and how session management is handled.
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    private final JwtAuthFilter jwtAuthFilter;

    // Inject our own JWT filter.
    public SecurityConfig(JwtAuthFilter jwtAuthFilter) {
        this.jwtAuthFilter = jwtAuthFilter;
    }

    /**
     * Password hashing algorithm (BCrypt).
     * Passwords are never stored in plain text in the database.
     * We hash the password with this bean at registration, and check it the same way at login.
     */
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    /**
     * Security filter chain.
     * Every incoming HTTP request passes through this chain; rules are applied in order.
     */
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                // 1. DISABLE CSRF
                // We built a stateless, JWT (token) based API, so we don't need protection
                // against browser-session-based CSRF attacks. Leaving this enabled would make
                // POST/PUT requests fail with 403.
                .csrf(AbstractHttpConfigurer::disable)

                // 2. ENABLE CORS
                // The frontend (React/Vue) is served from a different origin, so we apply the
                // CORS rules defined in 'CorsConfig'.
                .cors(cors -> cors.configure(http))

                // 3. DISABLE THE CLASSIC LOGIN METHODS
                // We're building a REST API: no HTML login page (form login), and no browser
                // login popup (HTTP Basic).
                .formLogin(AbstractHttpConfigurer::disable)
                .httpBasic(AbstractHttpConfigurer::disable)

                // 4. DISABLE THE DEFAULT USER-DETAILS SERVICE
                // Spring Boot auto-configures a "user" account with a randomly generated
                // password at startup unless told otherwise. We manage our own user table,
                // so this default behavior is disabled.
                .userDetailsService(username -> null)

                // 5. SESSION MANAGEMENT (STATELESS) - VERY IMPORTANT!
                // No server-side session is kept. Every request must carry its own token to
                // prove its identity. This keeps server memory usage flat and the app easy to scale.
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))

                // 6. AUTHORIZATION RULES
                // Who can access which URL? (Rules are evaluated top to bottom.)
                .authorizeHttpRequests(auth -> auth

                        // --- A. SWAGGER / DOCUMENTATION ---
                        // The documentation page is open to everyone (no login required).
                        .requestMatchers(
                                "/v3/api-docs/**",
                                "/swagger-ui/**",
                                "/swagger-ui.html"
                        ).permitAll()

                        // --- B. PUBLIC ENDPOINTS (open to everyone) ---
                        // No token is required for register, login, forgot-password, etc.
                        .requestMatchers(
                                "/api/users/register",
                                "/api/users/login",
                                "/api/users/refresh",
                                "/api/verification/**",
                                "/google/auth",
                                "/google/verify-status",
                                "/auth/password-reset",
                                "/auth/password-reset/set-password",
                                "/auth/password-reset/confirm-code",
                                "/uploads/**"
                        ).permitAll()


                        // --- C. ROLE-BASED RESTRICTIONS ---
                        // Note: roles are stored in the database as "ROLE_FARMER" etc.
                        // Spring Security automatically prepends "ROLE_" when we write hasRole('FARMER').

                        // FARMER operations.
                        // GET can also be used by a customer (product listings, etc.),
                        // but create/update/delete is farmer-only.
                        .requestMatchers(HttpMethod.GET, "/farmer/**").hasAnyRole("FARMER", "CUSTOMER")
                        .requestMatchers(HttpMethod.POST, "/farmer/**").hasRole("FARMER")
                        .requestMatchers(HttpMethod.PUT, "/farmer/**").hasRole("FARMER")
                        .requestMatchers(HttpMethod.DELETE, "/farmer/**").hasRole("FARMER")

                        // PRODUCT operations.
                        .requestMatchers(HttpMethod.GET, "/product/**").hasAnyRole("FARMER", "CUSTOMER")
                        .requestMatchers(HttpMethod.POST, "/product/**").hasRole("FARMER")
                        .requestMatchers(HttpMethod.PUT, "/product/**").hasRole("FARMER")
                        .requestMatchers(HttpMethod.DELETE, "/product/**").hasRole("FARMER")

                        // CUSTOMER operations.
                        .requestMatchers("/customer/**").hasRole("CUSTOMER")
                        // OrderController is mapped at "/api/orders" (not "/order/**"), so these
                        // endpoints rely on the customer's own "domainId" JWT claim as the
                        // customerId. Match the real path so the role check actually applies.
                        .requestMatchers(HttpMethod.POST, "/api/orders/create").hasRole("CUSTOMER")
                        .requestMatchers(HttpMethod.GET, "/api/orders/my-orders").hasRole("CUSTOMER")
                        .requestMatchers(HttpMethod.GET, "/api/orders/*").hasRole("CUSTOMER")

                        // TRUCKER operations.
                        .requestMatchers(HttpMethod.GET, "/truck/**").hasAnyRole("TRUCKER", "CUSTOMER")
                        .requestMatchers(HttpMethod.POST, "/truck/**").hasRole("TRUCKER")
                        .requestMatchers(HttpMethod.PUT, "/truck/**").hasRole("TRUCKER")
                        .requestMatchers(HttpMethod.DELETE, "/truck/**").hasRole("TRUCKER")

                        // Truck ads (Truck Ad Controller).
                        .requestMatchers(HttpMethod.GET, "/truck/ads/**").hasAnyRole("TRUCKER", "CUSTOMER")
                        .requestMatchers(HttpMethod.POST, "/truck/ads/**").hasRole("TRUCKER")
                        .requestMatchers(HttpMethod.PATCH, "/truck/ads/**").hasRole("TRUCKER")
                        .requestMatchers(HttpMethod.DELETE, "/truck/ads/**").hasRole("TRUCKER")

                        // DEPOT operations.
                        .requestMatchers(HttpMethod.GET, "/depot/**").hasAnyRole("DEPOT_OWNER", "FARMER", "CUSTOMER")
                        .requestMatchers(HttpMethod.POST, "/depot/**").hasRole("DEPOT_OWNER")
                        .requestMatchers(HttpMethod.PUT, "/depot/**").hasRole("DEPOT_OWNER")
                        .requestMatchers(HttpMethod.DELETE, "/depot/**").hasRole("DEPOT_OWNER")

                        // --- D. EVERYTHING ELSE ---
                        // Any request not covered above must at least be authenticated
                        // (a valid token).
                        .anyRequest().authenticated()

                )

                // 7. ADD TO THE FILTER CHAIN
                // Run our 'jwtAuthFilter' BEFORE Spring Security's own
                // UsernamePasswordAuthenticationFilter, so a valid token authenticates the
                // user automatically.
                .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}