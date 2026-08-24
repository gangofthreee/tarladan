package com.gangofthree.tarladan.modules.passwordReset.controller;


import com.gangofthree.tarladan.modules.passwordReset.dto.PasswordResetRequest;
import com.gangofthree.tarladan.modules.passwordReset.dto.PasswordConfirmCodeRequest;
import com.gangofthree.tarladan.modules.passwordReset.dto.PasswordSetRequest;
import com.gangofthree.tarladan.modules.passwordReset.service.PasswordResetService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class PasswordResetController {

    private final PasswordResetService passwordResetService;

    @PostMapping("/password-reset")
    public ResponseEntity<String> requestReset(@RequestBody PasswordResetRequest request) {
        passwordResetService.requestReset(request.getEmail());
        return ResponseEntity.ok("Reset code sent to email.");
    }

    @PostMapping("/password-reset/confirm-code")
    public ResponseEntity<String> confirmCode(
            @RequestBody PasswordConfirmCodeRequest request,
            HttpSession session
    ) {
        passwordResetService.confirmCode(request.getResetCode());

        // Store the verified reset code in the session
        session.setAttribute("verified-reset-code", request.getResetCode());

        return ResponseEntity.ok("Reset code verified.");
    }

    @PostMapping("/password-reset/set-password")
    public ResponseEntity<String> setPassword(
            @RequestBody PasswordSetRequest request,
            HttpSession session
    ) {
        String resetCode = (String) session.getAttribute("verified-reset-code");

        passwordResetService.setNewPassword(resetCode, request.getNewPassword());

        session.invalidate();

        return ResponseEntity.ok("Password updated successfully.");
    }
}

