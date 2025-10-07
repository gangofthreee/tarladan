package com.gangofthree.tarladan.modules.verification.controller;

import com.gangofthree.tarladan.modules.user.dto.VerifyCodeRequest;
import com.gangofthree.tarladan.modules.verification.service.VerificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/verification")
@RequiredArgsConstructor
public class VerificationController {

    private final VerificationService verificationService;

    @PostMapping("/verifyCode")
    public ResponseEntity<String> verifyCode(@RequestBody VerifyCodeRequest request) {
        boolean result = verificationService.verifyCode(request);

        if (result) {
            return ResponseEntity.ok("✅ Email başarıyla doğrulandı!");
        } else {
            return ResponseEntity.badRequest().body("❌ Doğrulama başarısız! Kod hatalı veya süresi dolmuş.");
        }
    }

    @PostMapping("/resendCode")
    public ResponseEntity<String> resendCode(@RequestParam String email) {
        verificationService.resendCode(email);
        return ResponseEntity.ok("Yeni kod gönderildi");
    }
}

