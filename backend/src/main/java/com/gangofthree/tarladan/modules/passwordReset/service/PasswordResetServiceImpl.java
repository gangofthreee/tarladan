package com.gangofthree.tarladan.modules.passwordReset.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.gangofthree.tarladan.infrastructure.mail.MailService;
import com.gangofthree.tarladan.modules.user.entity.User;
import com.gangofthree.tarladan.modules.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.security.SecureRandom;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.TimeUnit;

@Service
@RequiredArgsConstructor
@Slf4j
public class PasswordResetServiceImpl implements PasswordResetService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final MailService mailService;
    private final StringRedisTemplate redis;
    private final ObjectMapper objectMapper = new ObjectMapper();
    private final SecureRandom secureRandom = new SecureRandom();


    @Override
    public void requestReset(String email) {

        // Look up the account, but never reveal to the caller whether the email exists
        // (avoids email-enumeration via this endpoint).
        Optional<User> userOpt = userRepository.findByEmail(email);
        if (userOpt.isEmpty()) {
            log.debug("Password reset requested for an email with no matching account.");
            return;
        }

        // Generate a 6-digit reset code
        String code = generate6DigitCode();

        // Store the code and its metadata in Redis
        Map<String, Object> data = Map.of(
                "email", email,
                "resetCode", code,
                "verified", false,
                "used", false
        );

        try {
            redis.opsForValue().set(
                    "password-reset:" + code,
                    objectMapper.writeValueAsString(data),
                    3, TimeUnit.MINUTES
            );
        } catch (JsonProcessingException e) {
            throw new RuntimeException(e);
        }

        // Send the code by email
        mailService.sendResetCode(email, code);
    }


    @Override
    public void confirmCode(String resetCode) {

        String key = "password-reset:" + resetCode;
        String json = redis.opsForValue().get(key);

        if (json == null) {
            throw new IllegalArgumentException("Invalid or expired reset code.");
        }

        try {
            Map data = objectMapper.readValue(json, Map.class);
            data.put("verified", true);

            redis.opsForValue().set(
                    key,
                    objectMapper.writeValueAsString(data),
                    3, TimeUnit.MINUTES
            );

        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }


    @Override
    public void setNewPassword(String resetCode, String newPassword) {

        String key = "password-reset:" + resetCode;
        String json = redis.opsForValue().get(key);

        if (json == null) {
            throw new IllegalArgumentException("Reset code expired.");
        }

        try {
            Map<String, Object> data = objectMapper.readValue(json, Map.class);

            boolean verified = (boolean) data.get("verified");
            boolean used = (boolean) data.get("used");

            if (!verified) {
                throw new IllegalStateException("Reset code is not verified.");
            }

            if (used) {
                throw new IllegalStateException("Reset code already used.");
            }

            String email = (String) data.get("email");

            User user = userRepository.findByEmail(email)
                    .orElseThrow(() -> new IllegalArgumentException("User not found."));

            // Hash and persist the new password
            user.setPassword(passwordEncoder.encode(newPassword));
            userRepository.save(user);

            // Invalidate the reset code so it cannot be reused (one-time use)
            redis.delete(key);

        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }



    private String generate6DigitCode() {
        return String.format("%06d", secureRandom.nextInt(1_000_000));
    }
}

