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

    //kullanici kayitli mi? kayitliysa girisini yap (token uret, tokenresponse dondur) degil ise false dondur
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

    // yeni kullaniciyi save et, token uret girisini yap token response dondur
    @PostMapping("/auth")
    public ResponseEntity<TokenResponse> processAuth(@Valid @RequestBody GoogleRegisterRequest request) {
        try {
            TokenResponse response = googleService.processAuth(request);
            return ResponseEntity.status(HttpStatus.CREATED).body(response); // Kayıt olduğu için 201 Created .

        } catch (RuntimeException e) {
            // İş mantığı veya doğrulama hataları (örn. geçersiz rol, phone formatı)
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(TokenResponse.builder().message("Yeni kullanıcı kayıt işlemi başarısız: " + e.getMessage()).build());
        }
    }
}
