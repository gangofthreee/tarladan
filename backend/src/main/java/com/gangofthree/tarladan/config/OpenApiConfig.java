package com.gangofthree.tarladan.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * OpenAPI (Swagger) Dokümantasyon Ayarları
 * * Bu sınıf, http://localhost:8080/swagger-ui/index.html adresindeki sayfanın
 * başlığını, açıklamasını ve en önemlisi "Authorize" (Giriş Yap/Kilit) butonunun
 * çalışma mantığını yapılandırır.
 */
@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
                // ---------------------------------------------------------------------
                // 1. API KÜNYESİ (Info)
                // ---------------------------------------------------------------------
                // Swagger sayfasının en tepesinde görünen başlık, versiyon ve açıklama bilgileri.
                .info(new Info()
                        .title("Tarladan API")
                        .version("1.0")
                        .description("Tarladan projesi için Backend API dokümantasyonu."))

                // ---------------------------------------------------------------------
                // 2. GÜVENLİK GEREKSİNİMİ (Kilit Simgesi)
                // ---------------------------------------------------------------------
                // Bu satır, "bearerAuth" adını verdiğimiz güvenlik şemasını
                // varsayılan olarak tüm endpoint'lere uygular.
                // Yani sayfa açıldığında tüm endpointlerin yanında "Kilit" simgesi çıkar.
                .addSecurityItem(new SecurityRequirement().addList("bearerAuth"))

                // ---------------------------------------------------------------------
                // 3. GÜVENLİK ŞEMASI TANIMI (Authorize Butonu)
                // ---------------------------------------------------------------------
                // Burada "bearerAuth"un teknik detaylarını tanımlıyoruz.
                // Swagger'a diyoruz ki: "Biz JWT kullanıyoruz, token'ı Header'a ekle."
                .components(new Components()
                        .addSecuritySchemes("bearerAuth", // Bu isim yukarıdaki .addList() ile AYNI olmalı
                                new SecurityScheme()
                                        .type(SecurityScheme.Type.HTTP) // Tip: HTTP
                                        .scheme("bearer")               // Şema: Bearer Token
                                        .bearerFormat("JWT")));         // Format: JWT (Bilgi amaçlıdır)
    }
}