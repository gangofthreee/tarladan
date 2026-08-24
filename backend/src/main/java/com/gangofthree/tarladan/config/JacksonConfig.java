package com.gangofthree.tarladan.config;

import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Jackson JSON library configuration.
 * * Spring Boot uses the Jackson library by default for JSON processing.
 * This class defines the rules for JSON <-> Java object conversion.
 * Date formats and data mismatches in particular are handled here.
 */
@Configuration
public class JacksonConfig {

    @Bean
    public ObjectMapper objectMapper() {
        // ObjectMapper is the main class that performs JSON serialization/deserialization.
        ObjectMapper mapper = new ObjectMapper();

        // ---------------------------------------------------------------------
        // 1. UNKNOWN FIELD CHECK (Strict Mode)
        // ---------------------------------------------------------------------
        // Scenario: the frontend sent { "name": "Ali", "age": 25, "extraField": "test" }
        // but our Java class (DTO) only has 'name' and 'age'.
        //
        // true  -> THROW (UnrecognizedPropertyException). The API is validated strictly.
        // false -> IGNORE. Extra data is silently dropped, no error is raised.
        //
        // Current setting: TRUE (a request with extra fields will be rejected).
        mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, true);

        // ---------------------------------------------------------------------
        // 2. DATE/TIME MODULE (Java 8 Date/Time Support)
        // ---------------------------------------------------------------------
        // This module is required for Jackson to correctly handle modern Java 8
        // date/time types such as LocalDate and LocalDateTime.
        //
        // Without this module, dates render as: [2023, 11, 29] (array)
        // With this module, dates render as: "2023-11-29" (ISO string)
        mapper.registerModule(new JavaTimeModule());

        return mapper;
    }
}