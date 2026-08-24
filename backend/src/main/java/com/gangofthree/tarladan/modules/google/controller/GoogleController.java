package com.gangofthree.tarladan.modules.google.controller;

import com.gangofthree.tarladan.shared.dto.TokenResponse;
import com.gangofthree.tarladan.modules.google.dto.AuthStatusResponse;
import com.gangofthree.tarladan.modules.google.dto.GoogleAuthRequest;
import com.gangofthree.tarladan.modules.google.dto.GoogleRegisterRequest;
import com.gangofthree.tarladan.modules.google.service.GoogleService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/google")
@RequiredArgsConstructor
public class GoogleController {
    private final GoogleService googleService;

    // Is the user already registered? If so, log them in (issue a token and return a TokenResponse).
    // If not, return false.
    @PostMapping("/verify-status")
    public ResponseEntity<?> verifyStatus(@Valid @RequestBody GoogleAuthRequest request) {
        try {
            AuthStatusResponse response = googleService.verifyStatus(request);
            return ResponseEntity.ok(response);
        }catch (RuntimeException e){
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(TokenResponse.builder().message("Token doğrulama başarısız: " + e.getMessage()).build());
        }
    }

    // Save the new user, issue a token, log them in, and return a TokenResponse.
    @PostMapping("/auth")
    public ResponseEntity<TokenResponse> processAuth(@Valid @RequestBody GoogleRegisterRequest request) {
        try {
            TokenResponse response = googleService.processAuth(request);
            return ResponseEntity.status(HttpStatus.CREATED).body(response); // 201 Created: a new account was registered.

        } catch (RuntimeException e) {
            // Business rule or validation errors (e.g. invalid role, invalid phone format)
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(TokenResponse.builder().message("Yeni kullanıcı kayıt işlemi başarısız: " + e.getMessage()).build());
        }
    }
}
