package com.gangofthree.tarladan.common.config;

import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
// import com.fasterxml.jackson.databind.Module; // Artık buna gerek yok
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule; // Sadece bu yeterli
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class JacksonConfig {

    @Bean
    public ObjectMapper objectMapper() {
        ObjectMapper mapper = new ObjectMapper();

        // 1. Deserilization kuralını uygulayın.
        mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, true);

        // 2. ÇÖZÜM: JavaTimeModule'ü doğrudan ObjectMapper'a kaydedin.
        // Bu, Jackson'a LocalDate, LocalDateTime gibi tipleri nasıl işleyeceğini söyler.
        mapper.registerModule(new JavaTimeModule());

        return mapper;
    }

    // Artık bu metoda gerek yok, çünkü modülü yukarıda kaydettik.
    // @Bean
    // public Module javaTimeModule() {
    //     return new JavaTimeModule();
    // }
}