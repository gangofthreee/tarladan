package com.gangofthree.tarladan.modules.user.controller;

import com.gangofthree.tarladan.common.dto.TokenResponse;
import com.gangofthree.tarladan.common.utils.JwtUtil;
import com.gangofthree.tarladan.core.service.TokenService;
import com.gangofthree.tarladan.modules.user.dto.UserLoginRequest;
import com.gangofthree.tarladan.modules.user.dto.UserLoginResponse;
import com.gangofthree.tarladan.modules.user.dto.UserRegisterRequest;
import com.gangofthree.tarladan.modules.user.entity.User;
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
    private final JwtUtil jwtUtil;

    @PostMapping("/register")
    public ResponseEntity<User> register(@Valid @RequestBody UserRegisterRequest request) {
        User savedUser = userService.register(request);
        return ResponseEntity.ok(savedUser);
    }

    @PostMapping("/login")
    public ResponseEntity<TokenResponse> login(@Valid @RequestBody UserLoginRequest request) {
        // UserService'deki login metodu artık TokenResponse dönecek.
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


}
