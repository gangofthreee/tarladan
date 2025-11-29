package com.gangofthree.tarladan.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.http.converter.HttpMessageNotReadableException;

import java.util.HashMap;
import java.util.Map;

/**
 * Merkezi Hata Yönetimi (Global Exception Handling)
 * * @ControllerAdvice anotasyonu, bu sınıfın bir "Interceptor" (Araya giren) olduğunu belirtir.
 * Uygulamanın herhangi bir Controller'ında bir hata (Exception) fırlatıldığında,
 * Spring Boot otomatik olarak buraya gelir ve uygun @ExceptionHandler metodunu çalıştırır.
 * Böylece Controller'lar içinde try-catch yazmaktan kurtuluruz.
 */
@ControllerAdvice
public class GlobalExceptionHandler {

    /**
     * DTO Validasyon Hatalarını Yakalar (@Valid)
     * * Frontend'den gelen veride eksik veya hatalı alan varsa (Örn: @NotNull, @Email, @Size)
     * Spring Boot 'MethodArgumentNotValidException' fırlatır.
     * * Bu metot, karmaşık Java hata logunu, Frontend'in anlayacağı basit bir
     * "Alan Adı : Hata Mesajı" haritasına (Map) çevirir.
     * Örn: { "email": "Geçerli bir email giriniz", "password": "En az 6 karakter olmalı" }
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, String>> handleValidationExceptions(
            MethodArgumentNotValidException ex) {
        Map<String, String> errors = new HashMap<>();

        // Hatalı olan tüm alanları tek tek gez ve map'e ekle
        ex.getBindingResult().getAllErrors().forEach(error -> {
            String fieldName = ((FieldError) error).getField();
            String errorMessage = error.getDefaultMessage();
            errors.put(fieldName, errorMessage);
        });

        return new ResponseEntity<>(errors, HttpStatus.BAD_REQUEST);
    }

    /**
     * Güvenlik ve Yetki Hataları
     * * Kodun içinde manuel olarak 'throw new SecurityException("Bu işlem için yetkiniz yok")'
     * dediğinizde bu metot devreye girer.
     * Kullanıcıya 403 (Forbidden) statüsünü döner.
     */
    @ExceptionHandler(SecurityException.class)
    public ResponseEntity<String> handleSecurityException(SecurityException ex) {
        // 403 Forbidden olarak frontend'e gönder
        return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(ex.getMessage());
    }

    /**
     * İş Mantığı Hataları (Service Katmanı)
     * * Service katmanında "Stok yetersiz", "Kullanıcı bulunamadı", "ID negatif olamaz"
     * gibi durumlar için genelde 'IllegalArgumentException' fırlatırız.
     * Bu metot, bu tür iş kuralı ihlallerini yakalar ve 400 Bad Request döner.
     */
    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<Map<String, String>> handleIllegalArgumentException(IllegalArgumentException ex) {
        Map<String, String> error = new HashMap<>();
        error.put("error", ex.getMessage());
        return new ResponseEntity<>(error, HttpStatus.BAD_REQUEST);
    }

    /**
     * JSON Format Hataları (Malformed JSON)
     * * Kullanıcı JSON yerine bozuk bir veri yollarsa,
     * virgülü unutursa veya Integer beklenen yere String ("yas": "yirmi") yazarsa
     * bu hata fırlatılır.
     * Ayrıca JacksonConfig'de 'FAIL_ON_UNKNOWN_PROPERTIES' true olduğu için,
     * tanınmayan bir alan geldiğinde de burası çalışır.
     */
    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<Map<String, String>> handleHttpMessageNotReadable(HttpMessageNotReadableException ex) {
        Map<String, String> error = new HashMap<>();
        // Güvenlik gereği hatanın tüm detayını (Java stack trace) dışarı açmıyoruz.
        // Sadece formatın yanlış olduğunu söylüyoruz.
        error.put("error", "Gönderilen JSON formatı hatalı veya bilinmeyen alanlar içeriyor.");
        return new ResponseEntity<>(error, HttpStatus.BAD_REQUEST);
    }
}