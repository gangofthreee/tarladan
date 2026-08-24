package com.gangofthree.tarladan.config;

import com.gangofthree.tarladan.interceptor.RateLimitInterceptor;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
@RequiredArgsConstructor
public class WebConfig implements WebMvcConfigurer {

    private final RateLimitInterceptor rateLimitInterceptor;

    /**
     * Rate limiting interceptor registration.
     * Selects which requests get a rate limit applied and which don't.
     */
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(rateLimitInterceptor)
                .addPathPatterns("/**") // Protect everything by default...
                // ...EXCEPT the following (no rate limit applied):
                .excludePathPatterns(
                        "/uploads/**",          // uploaded images shouldn't count against the quota
                        "/static/**",           // static files
                        "/swagger-ui/**",       // Swagger UI
                        "/v3/api-docs/**",      // Swagger JSON data
                        "/webjars/**",
                        "/error"                // Spring Boot's error page
                );
    }

    /**
     * Static resource handlers.
     * Serves uploaded files.
     */
    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/uploads/**")
                .addResourceLocations("file:/app/uploads/");
    }

    /**
     * Shared RestTemplate bean for outbound HTTP calls (e.g. Google token verification),
     * so callers don't each construct their own instance.
     */
    @Bean
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }
}