package com.gangofthree.tarladan.service;

import com.gangofthree.tarladan.dto.UserRegisterRequest;
import com.gangofthree.tarladan.entity.User;
import com.gangofthree.tarladan.enums.UserRole;
import com.gangofthree.tarladan.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public User register(UserRegisterRequest request) {
        // email & phone kontrolü
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new IllegalArgumentException("Email already in use");
        }
        if (userRepository.existsByPhone(request.getPhone())) {
            throw new IllegalArgumentException("Phone already in use");
        }

        String roleString = String.valueOf(request.getRole()); // null olsa bile "null" string olur
        UserRole userRole;
        try {
            userRole = UserRole.valueOf(roleString.toUpperCase()); // büyük harf ile enum karşılaştırması
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("Invalid role provided: " + roleString);
        }


        // Password Hashleme
        String encodedPassword = passwordEncoder.encode(request.getPassword());

        User user = User.builder()
                .name(request.getName())
                .surname(request.getSurname())
                .phone(request.getPhone())
                .email(request.getEmail())
                .password(encodedPassword)
                .role(request.getRole())
                .build();

        return userRepository.save(user);
    }
}

