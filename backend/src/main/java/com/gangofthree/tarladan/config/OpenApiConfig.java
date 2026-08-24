package com.gangofthree.tarladan.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * OpenAPI (Swagger) documentation settings.
 * * This class configures the title and description shown on the page at
 * http://localhost:8080/swagger-ui/index.html, and — most importantly —
 * how the "Authorize" (login/lock) button behaves.
 */
@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
                // ---------------------------------------------------------------------
                // 1. API INFO
                // ---------------------------------------------------------------------
                // Title, version, and description shown at the top of the Swagger page.
                .info(new Info()
                        .title("Tarladan API")
                        .version("1.0")
                        .description("Backend API documentation for the Tarladan project."))

                // ---------------------------------------------------------------------
                // 2. SECURITY REQUIREMENT (Lock Icon)
                // ---------------------------------------------------------------------
                // Applies the security scheme named "bearerAuth" to all endpoints by
                // default, so a lock icon appears next to every endpoint on the page.
                .addSecurityItem(new SecurityRequirement().addList("bearerAuth"))

                // ---------------------------------------------------------------------
                // 3. SECURITY SCHEME DEFINITION (Authorize Button)
                // ---------------------------------------------------------------------
                // Defines the technical details of "bearerAuth": tells Swagger
                // "we use JWT, attach the token to the Header."
                .components(new Components()
                        .addSecuritySchemes("bearerAuth", // This name must match .addList() above
                                new SecurityScheme()
                                        .type(SecurityScheme.Type.HTTP) // Type: HTTP
                                        .scheme("bearer")               // Scheme: Bearer Token
                                        .bearerFormat("JWT")));         // Format: JWT (informational only)
    }
}