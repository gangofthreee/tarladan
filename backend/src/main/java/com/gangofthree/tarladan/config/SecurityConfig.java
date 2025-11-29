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
 * Spring Security Ana Yapılandırması
 * * Bu sınıf, uygulamanın güvenlik duvarıdır.
 * HTTP isteklerinin nasıl filtreleneceğini, kimlerin nereye erişebileceğini
 * ve oturum yönetiminin (Session) nasıl yapılacağını belirler.
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    private final JwtAuthFilter jwtAuthFilter;

    // Kendi yazdığımız JWT Filtresini buraya enjekte ediyoruz.
    public SecurityConfig(JwtAuthFilter jwtAuthFilter) {
        this.jwtAuthFilter = jwtAuthFilter;
    }

    /**
     * Şifreleme Algoritması (BCrypt)
     * Veritabanında şifreleri asla düz metin (plain-text) olarak saklamayız.
     * Kullanıcı kayıt olurken şifresini bu Bean ile hashleyip kaydederiz.
     * Giriş yaparken de girilen şifreyi yine bununla kontrol ederiz.
     */
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    /**
     * Güvenlik Zinciri (Security Filter Chain)
     * Gelen her HTTP isteği bu zincirden geçer. Kurallar sırayla uygulanır.
     */
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                // 1. CSRF (Cross-Site Request Forgery) İPTAL
                // Biz JWT (Token) tabanlı stateless bir yapı kurduğumuz için
                // tarayıcı oturumlarına dayalı CSRF saldırılarına karşı korumaya ihtiyacımız yok.
                // Bunu kapatmazsak POST/PUT istekleri 403 hatası alabilir.
                .csrf(AbstractHttpConfigurer::disable)

                // 2. CORS (Cross-Origin Resource Sharing) AKTİF
                // Frontend (React/Vue) farklı bir porttan geleceği için CORS ayarlarını
                // 'CorsConfig' sınıfından al ve uygula diyoruz.
                .cors(cors -> cors.configure(http))

                // 3. KLASİK GİRİŞ YÖNTEMLERİ İPTAL
                // Biz REST API yazıyoruz. HTML login sayfası (FormLogin) istemiyoruz.
                // Tarayıcı popup'ı ile giriş (HttpBasic) istemiyoruz.
                .formLogin(AbstractHttpConfigurer::disable)
                .httpBasic(AbstractHttpConfigurer::disable)

                // 4. VARSAYILAN USER SERVICE İPTAL
                // Spring Boot başlangıçta "user" adında ve rastgele şifreli bir kullanıcı oluşturur.
                // Biz kendi kullanıcı tablomuzu yöneteceğimiz için bu varsayılan davranışı kapatıyoruz.
                .userDetailsService(username -> null)

                // 5. OTURUM YÖNETİMİ (Stateless) - ÇOK ÖNEMLİ!
                // Sunucu tarafında hiçbir oturum (Session) tutma diyoruz.
                // Her istek, kimliğini ispatlamak için kendi Token'ını getirmek zorundadır.
                // Bu sayede sunucu RAM'i şişmez ve uygulama kolayca ölçeklenebilir.
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))

                // 6. YETKİLENDİRME KURALLARI (Authorization)
                // Hangi URL'e kim girebilir? (Yukarıdan aşağıya sırayla işler)
                .authorizeHttpRequests(auth -> auth

                        // --- A. SWAGGER / DOKÜMANTASYON ---
                        // Dokümantasyon sayfasına herkes girebilmeli (Login olmadan).
                        .requestMatchers(
                                "/v3/api-docs/**",
                                "/swagger-ui/**",
                                "/swagger-ui.html"
                        ).permitAll()

                        // --- B. PUBLIC ENDPOINTLER (Herkes Girebilir) ---
                        // Kayıt ol, Giriş yap, Şifremi unuttum gibi işlemlerde token sorulmaz.
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


                        // --- C. ROL BAZLI KISITLAMALAR ---
                        // Not: Veritabanında roller "ROLE_FARMER" diye kayıtlıdır.
                        // Spring Security "hasRole('FARMER')" dediğimizde otomatik başına "ROLE_" ekler.

                        // FARMER (Çiftçi) İşlemleri
                        // GET işlemini Müşteri de görebilir (Ürün listeleme vb.)
                        // Ama Ekleme/Silme/Güncelleme sadece Çiftçi yapabilir.
                        .requestMatchers(HttpMethod.GET, "/farmer/**").hasAnyRole("FARMER", "CUSTOMER")
                        .requestMatchers(HttpMethod.POST, "/farmer/**").hasRole("FARMER")
                        .requestMatchers(HttpMethod.PUT, "/farmer/**").hasRole("FARMER")
                        .requestMatchers(HttpMethod.DELETE, "/farmer/**").hasRole("FARMER")

                        // PRODUCT (Ürün) İşlemleri
                        .requestMatchers(HttpMethod.GET, "/product/**").hasAnyRole("FARMER", "CUSTOMER")
                        .requestMatchers(HttpMethod.POST, "/product/**").hasRole("FARMER")
                        .requestMatchers(HttpMethod.PUT, "/product/**").hasRole("FARMER")
                        .requestMatchers(HttpMethod.DELETE, "/product/**").hasRole("FARMER")

                        // CUSTOMER (Müşteri) İşlemleri
                        .requestMatchers("/customer/**").hasRole("CUSTOMER")
                        .requestMatchers("/order/**").hasRole("CUSTOMER")

                        // TRUCKER (Nakliyeci) İşlemleri
                        .requestMatchers(HttpMethod.GET, "/truck/**").hasAnyRole("TRUCKER", "CUSTOMER")
                        .requestMatchers(HttpMethod.POST, "/truck/**").hasRole("TRUCKER")
                        .requestMatchers(HttpMethod.PUT, "/truck/**").hasRole("TRUCKER")
                        .requestMatchers(HttpMethod.DELETE, "/truck/**").hasRole("TRUCKER")

                        // Nakliye İlanları
                        .requestMatchers(HttpMethod.GET, "/truckAd/**").hasAnyRole("TRUCKER", "CUSTOMER")
                        .requestMatchers(HttpMethod.POST, "/truckAd/**").hasRole("TRUCKER")
                        .requestMatchers(HttpMethod.PUT, "/truckAd/**").hasRole("TRUCKER")
                        .requestMatchers(HttpMethod.DELETE, "/truckAd/**").hasRole("TRUCKER")

                        // DEPOT (Depo Sahibi) İşlemleri
                        .requestMatchers(HttpMethod.GET, "/depot/**").hasAnyRole("DEPOT_OWNER", "FARMER", "CUSTOMER")
                        .requestMatchers(HttpMethod.POST, "/depot/**").hasRole("DEPOT_OWNER")
                        .requestMatchers(HttpMethod.PUT, "/depot/**").hasRole("DEPOT_OWNER")
                        .requestMatchers(HttpMethod.DELETE, "/depot/**").hasRole("DEPOT_OWNER")

                        // --- D. DİĞER HER ŞEY ---
                        // Yukarıda tanımlanmamış herhangi bir istek gelirse,
                        // mutlaka giriş yapılmış (Token geçerli) olmalıdır.
                        .anyRequest().authenticated()

                )

                // 7. FİLTRE ZİNCİRİNE EKLEME
                // Spring Security'nin kendi UsernamePasswordAuthenticationFilter'ı çalışmadan ÖNCE
                // bizim yazdığımız 'jwtAuthFilter' devreye girsin.
                // Böylece token varsa, kullanıcıyı sistem otomatik tanısın.
                .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}