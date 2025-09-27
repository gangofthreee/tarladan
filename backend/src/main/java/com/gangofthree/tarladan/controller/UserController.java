package com.gangofthree.tarladan.controller;

import com.gangofthree.tarladan.dto.UserRegisterRequest;
import com.gangofthree.tarladan.entity.User;
import com.gangofthree.tarladan.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @PostMapping("/register")
    public ResponseEntity<User> register(@Valid @RequestBody UserRegisterRequest request) {
        User savedUser = userService.register(request);
        return ResponseEntity.ok(savedUser);
    }
}

