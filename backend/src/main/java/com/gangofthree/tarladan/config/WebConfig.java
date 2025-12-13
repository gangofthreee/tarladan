package com.gangofthree.tarladan.config;

import com.gangofthree.tarladan.interceptor.RateLimitInterceptor;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
@RequiredArgsConstructor
public class WebConfig implements WebMvcConfigurer {

    private final RateLimitInterceptor rateLimitInterceptor;

    /**
     * Rate Limiting Interceptor Kaydı
     * Hangi isteklere limit uygulanıp hangilerine uygulanmayacağını burada seçiyoruz.
     */
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(rateLimitInterceptor)
                .addPathPatterns("/**") // Varsayılan olarak her şeyi koru
                // AŞAĞIDAKİLER HARİÇ (Rate Limit Uygulanmayacaklar):
                .excludePathPatterns(
                        "/uploads/**",          // Yüklenen resimler kotadan düşmesin
                        "/static/**",           // Statik dosyalar
                        "/swagger-ui/**",       // Swagger UI arayüzü
                        "/v3/api-docs/**",      // Swagger JSON verisi
                        "/webjars/**",
                        "/error"                // Spring Boot hata sayfası
                );
    }

    /**
     * Statik Kaynak İşleyicileri
     * Yüklenen dosyaların sunulması.
     */
    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/uploads/**")
                .addResourceLocations("file:/app/uploads/");
    }
}