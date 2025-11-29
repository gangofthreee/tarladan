package com.gangofthree.tarladan.config;

import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Jackson JSON Kütüphanesi Yapılandırması
 * * Spring Boot varsayılan olarak JSON işlemleri için Jackson kütüphanesini kullanır.
 * Bu sınıf, JSON <-> Java Nesnesi dönüşümlerinin kurallarını belirler.
 * Özellikle tarih formatları ve veri uyuşmazlıkları burada yönetilir.
 */
@Configuration
public class JacksonConfig {

    @Bean
    public ObjectMapper objectMapper() {
        // ObjectMapper, JSON serileştirme/ters-serileştirme yapan ana sınıftır.
        ObjectMapper mapper = new ObjectMapper();

        // ---------------------------------------------------------------------
        // 1. BİLİNMEYEN ALAN KONTROLÜ (Strict Mode)
        // ---------------------------------------------------------------------
        // Senaryo: Frontend { "name": "Ali", "age": 25, "extraField": "test" } yolladı.
        // Ama bizim Java sınıfımızda (DTO) sadece 'name' ve 'age' var.
        //
        // true  -> HATA FIRLAT (UnrecognizedPropertyException). API çok sıkı denetlenir.
        // false -> GÖRMEZDEN GEL. Fazladan gelen veriyi yok sayar, hata vermez. (Genelde önerilen budur).
        //
        // Şu anki ayarınız: TRUE (Fazla veri gelirse hata alırsınız).
        mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, true);

        // ---------------------------------------------------------------------
        // 2. TARİH VE SAAT MODÜLÜ (Java 8 Date/Time Support)
        // ---------------------------------------------------------------------
        // Java 8 ile gelen LocalDate, LocalDateTime gibi modern tarih tiplerini
        // Jackson'ın doğru işlemesi için bu modül zorunludur.
        //
        // Bu modül olmazsa tarihler şöyle görünür: [2023, 11, 29] (Array)
        // Bu modül varken tarihler şöyle görünür: "2023-11-29" (ISO String)
        mapper.registerModule(new JavaTimeModule());

        return mapper;
    }
}