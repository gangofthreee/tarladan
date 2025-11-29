package com.gangofthree.tarladan.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * Web MVC Yapılandırması (Statik Dosya Sunumu)
 * * Bu sınıf, Spring MVC'nin standart ayarlarını özelleştirmek için kullanılır.
 * En temel görevi: Kullanıcıların yüklediği resimlerin (Avatar, Ürün fotosu vb.)
 * tarayıcı üzerinden (URL ile) görüntülenebilmesini sağlamaktır.
 */
@Configuration
public class WebConfig implements WebMvcConfigurer {

    /**
     * Statik Kaynak İşleyicileri (Resource Handlers)
     * Normalde Spring Boot, sadece projenin içindeki 'src/main/resources/static'
     * klasörünü dışarı açar. Ancak kullanıcıların yüklediği dosyalar proje içinde değil,
     * sunucunun diskinde veya Docker container'ın içinde bir klasörde durur.
     */
    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {

        // KURAL:
        // Tarayıcıdan "http://localhost:8080/uploads/..." şeklinde gelen her isteği yakala.
        registry.addResourceHandler("/uploads/**")

                // HEDEF:
                // Bu istekleri sunucunun fiziksel dosya sistemindeki (file:)
                // "/app/uploads/" klasörüne yönlendir.
                //
                // ÖNEMLİ NOT:
                // "/app/uploads/" yolu Dockerfile veya Docker Compose içinde
                // oluşturduğumuz ve volume olarak bağladığımız yoldur.
                // Windows'ta çalışıyorsanız burası "file:C:/uploads/" gibi olabilir.
                .addResourceLocations("file:/app/uploads/");
    }
}