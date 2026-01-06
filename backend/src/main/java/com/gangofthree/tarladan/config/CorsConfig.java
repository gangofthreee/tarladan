package com.gangofthree.tarladan.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;

import java.util.Arrays;

/**
 * CORS (Cross-Origin Resource Sharing) Yapılandırması
 * * Bu sınıf, tarayıcı tabanlı frontend uygulamalarının (React, Angular, Vue vb.)
 * farklı bir domain veya port üzerinde çalışan bu Backend API'ye erişebilmesi için
 * gerekli izinleri tanımlar.
 */
@Configuration
public class CorsConfig {

    @Bean
    public CorsFilter corsFilter() {
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        CorsConfiguration config = new CorsConfiguration();

        // 1. KİMLİK BİLGİLERİ İZNİ (Credentials)
        // Frontend'in Backend'e Cookie veya 'Authorization' (Bearer Token) header'ı
        // gönderebilmesi için bunun 'true' olması ZORUNLUDUR.
        // Eğer bu kapalıysa, tarayıcı token içeren istekleri güvenlik nedeniyle engeller.
        config.setAllowCredentials(true);

        // 2. İZİN VERİLEN KAYNAKLAR (Origins)
        // Hangi adreslerden (Domain/Port) istek gelebilir?
        // setAllowedOrigins("*") yerine Pattern kullanıyoruz çünkü Credentials(true) olduğunda
        // joker karakter (*) kullanımı kısıtlanmıştır.
        // Ancak mobile app'lerden gelen istekleri kolaylaştırmak ve Azure domain sorununu çözmek için
        // geçici veya kalıcı olarak tüm (*) pattern'lere izin veriyoruz.
        config.setAllowedOriginPatterns(Arrays.asList("*"));

        // 3. İZİN VERİLEN BAŞLIKLAR (Headers)
        // Frontend'in istek atarken gönderebileceği Header tipleri.
        // "*" diyerek Content-Type, Authorization, X-Requested-With gibi her şeye izin veriyoruz.
        config.setAllowedHeaders(Arrays.asList("*"));

        // 4. İZİN VERİLEN HTTP METOTLARI
        // Backend'in kabul edeceği işlem türleri.
        // OPTIONS: Tarayıcının gönderdiği "Pre-flight" (Ön kontrol) isteği için gereklidir.
        config.setAllowedMethods(Arrays.asList(
                "GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"
        ));

        // 5. DIŞARIYA AÇILAN BAŞLIKLAR (Exposed Headers)
        // Normalde tarayıcılar, güvenlik gereği Backend'den dönen bazı özel Header'ları Frontend koduna gizler.
        // Frontend'in (örneğin Axios'un) bu headerları okuyabilmesi için onları ifşa etmeliyiz.
        // CORS hatası almamak için bu kısım önemlidir.
        config.setExposedHeaders(Arrays.asList(
                "Access-Control-Allow-Origin",
                "Access-Control-Allow-Credentials",
                "Authorization",        // Eğer token'ı header'da dönüyorsanız
                "X-New-Access-Token",   // JWT Token yenilemesi için - Frontend bu header'ı alıp kaydetmeli
                "X-Total-Count"         // Eğer sayfalama yapıyorsanız gerekebilir
        ));

        // 6. ÖN BELLEK SÜRESİ (Max Age)
        // Tarayıcı her POST/PUT isteğinden önce bir "OPTIONS" (Pre-flight) isteği atar.
        // Bu ayar, tarayıcıya "Bu izinleri 3600 saniye (1 saat) boyunca hatırla, her defasında sorma" der.
        // Bu sayede gereksiz trafik azalır ve uygulama hızlanır.
        config.setMaxAge(3600L);

        // 7. YOL TANIMLAMASI
        // Bu kuralların projedeki TÜM endpointler (/**) için geçerli olduğunu belirtir.
        source.registerCorsConfiguration("/**", config);

        return new CorsFilter(source);
    }
}