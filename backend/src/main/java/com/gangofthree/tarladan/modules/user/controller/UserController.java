package com.gangofthree.tarladan.modules.user.controller;

import com.gangofthree.tarladan.modules.user.dto.UserProfileResponse;
import com.gangofthree.tarladan.shared.dto.TokenResponse;
import com.gangofthree.tarladan.security.service.TokenService;
import com.gangofthree.tarladan.modules.user.dto.UserLoginRequest;
import com.gangofthree.tarladan.modules.user.dto.UserRegisterRequest;
import com.gangofthree.tarladan.modules.user.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;
    private final TokenService tokenService;

    @PostMapping("/register")
    public ResponseEntity<String> register(@Valid @RequestBody UserRegisterRequest request) {
        userService.register(request);
        return ResponseEntity.ok("Registration successful. Please check your email for verification code.");
    }

    @PostMapping("/login")
    public ResponseEntity<TokenResponse> login(@Valid @RequestBody UserLoginRequest request) {
        // UserService.login now returns a TokenResponse.
        TokenResponse response = userService.login(request);
        return ResponseEntity.ok(response);
    }


    @PostMapping("/logout")
    public ResponseEntity<Void> logout(@RequestHeader(HttpHeaders.AUTHORIZATION) String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return ResponseEntity.badRequest().build();
        }

        String accessToken = authHeader.substring(7);
        tokenService.logoutByAccessToken(accessToken);

        return ResponseEntity.ok().build();
    }

    @GetMapping("/me")
    public ResponseEntity<UserProfileResponse> getMyProfile() {
        // 1. Read the current user's id from the SecurityContext.
        // JwtAuthFilter builds the authentication as:
        // new UsernamePasswordAuthenticationToken(userId, ...), so getPrincipal()
        // returns the userId directly as a Long.
        Long userId = (Long) org.springframework.security.core.context.SecurityContextHolder
                .getContext().getAuthentication().getPrincipal();

        UserProfileResponse response = userService.getUserProfile(userId);
        return ResponseEntity.ok(response);
    }


}
