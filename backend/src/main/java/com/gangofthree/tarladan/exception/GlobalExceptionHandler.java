package com.gangofthree.tarladan.exception;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
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
 * Global exception handling.
 * * The @ControllerAdvice annotation marks this class as a cross-cutting interceptor:
 * whenever any Controller in the application throws an exception, Spring Boot
 * automatically routes it here and runs the matching @ExceptionHandler method.
 * This keeps Controllers free of repetitive try-catch blocks.
 */
@ControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    /**
     * Handles DTO validation errors (@Valid).
     * * When data sent by the frontend is missing or invalid (e.g. @NotNull, @Email, @Size),
     * Spring Boot throws MethodArgumentNotValidException.
     * * This method turns the verbose Java validation errors into a simple
     * "field name : error message" map the frontend can consume.
     * E.g.: { "email": "Please enter a valid email", "password": "Must be at least 6 characters" }
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, String>> handleValidationExceptions(
            MethodArgumentNotValidException ex) {
        Map<String, String> errors = new HashMap<>();

        // Walk through every invalid field and add it to the map.
        ex.getBindingResult().getAllErrors().forEach(error -> {
            String fieldName = ((FieldError) error).getField();
            String errorMessage = error.getDefaultMessage();
            errors.put(fieldName, errorMessage);
        });

        return new ResponseEntity<>(errors, HttpStatus.BAD_REQUEST);
    }

    /**
     * Security and authorization errors.
     * * Triggered when code manually throws 'new SecurityException("...")'.
     * Returns a 403 (Forbidden) status to the client.
     */
    @ExceptionHandler(SecurityException.class)
    public ResponseEntity<String> handleSecurityException(SecurityException ex) {
        log.warn("Security exception: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(ex.getMessage());
    }

    /**
     * Business rule violations (service layer).
     * * The service layer generally throws 'IllegalArgumentException' for cases like
     * "insufficient stock", "user not found", "id cannot be negative", etc.
     * This method catches those business rule violations and returns 400 Bad Request.
     */
    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<Map<String, String>> handleIllegalArgumentException(IllegalArgumentException ex) {
        Map<String, String> error = new HashMap<>();
        error.put("error", ex.getMessage());
        return new ResponseEntity<>(error, HttpStatus.BAD_REQUEST);
    }

    /**
     * Malformed JSON errors.
     * * Thrown when the client sends malformed data instead of valid JSON — a missing
     * comma, or a String ("age": "twenty") where an Integer was expected.
     * Also triggered when JacksonConfig's 'FAIL_ON_UNKNOWN_PROPERTIES' is true and an
     * unrecognized field is present in the request body.
     */
    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<Map<String, String>> handleHttpMessageNotReadable(HttpMessageNotReadableException ex) {
        Map<String, String> error = new HashMap<>();
        // For security reasons we don't expose the full error detail (Java stack trace).
        // We only tell the client that the request format was invalid.
        error.put("error", "Gönderilen JSON formatı hatalı veya bilinmeyen alanlar içeriyor.");
        return new ResponseEntity<>(error, HttpStatus.BAD_REQUEST);
    }

    /**
     * Catch-all fallback for any exception not handled above.
     * * Without this, an unexpected exception (a bug, a downstream service failure, etc.)
     * would fall through to Spring Boot's default error page instead of the consistent
     * JSON error shape used elsewhere in this class. We log the full exception server-side
     * for diagnosis, but deliberately avoid returning ex.getMessage() to the client so
     * internal details (SQL errors, stack traces, third-party error text) are never leaked.
     */
    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, String>> handleUnexpectedException(Exception ex) {
        log.error("Unhandled exception", ex);
        Map<String, String> error = new HashMap<>();
        error.put("error", "Beklenmeyen bir hata oluştu. Lütfen daha sonra tekrar deneyiniz.");
        return new ResponseEntity<>(error, HttpStatus.INTERNAL_SERVER_ERROR);
    }
}
