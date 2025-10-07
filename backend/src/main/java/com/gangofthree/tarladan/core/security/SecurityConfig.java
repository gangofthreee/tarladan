package com.gangofthree.tarladan.core.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.boot.autoconfigure.security.servlet.UserDetailsServiceAutoConfiguration;

@Configuration
@EnableWebSecurity

// Bu, Spring Boot'un varsayılan UserDetailsService (rastgele şifre üreten kısmı)
// otomatik yapılandırmasını tamamen devreden çıkarır.
@Import(UserDetailsServiceAutoConfiguration.class)
public class SecurityConfig {

    // Şifre hashleme için kullandığınız tek amaçlı Bean yerinde duruyor.
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                // 1. CSRF korumasını devre dışı bırakır (JWT için uygundur).
                .csrf(AbstractHttpConfigurer::disable)

                // 2. HTTP Basic ve Form tabanlı kimlik doğrulamasını devre dışı bırakır.
                .formLogin(AbstractHttpConfigurer::disable)
                .httpBasic(AbstractHttpConfigurer::disable)

                // 3. Varsayılan kullanıcı servislerini devre dışı bırakır. (@Import ile birlikte kesin çözüm sağlar).
                .userDetailsService(username -> null)

                // 4. Oturum Yönetimini Stateless olarak ayarlar.
                .sessionManagement(session -> session
                        .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
                )

                // 5. Yetkilendirme Kuralları: TÜM endpoint'lere kısıtlama olmadan erişim izni verir.
                .authorizeHttpRequests(auth -> auth
                        .anyRequest().permitAll()
                );

        return http.build();
    }
}

