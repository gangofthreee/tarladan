package com.gangofthree.tarladan.modules.passwordReset.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.gangofthree.tarladan.common.utils.MailService;
import com.gangofthree.tarladan.modules.passwordReset.service.PasswordResetService;
import com.gangofthree.tarladan.modules.user.entity.User;
import com.gangofthree.tarladan.modules.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.Random;
import java.util.concurrent.TimeUnit;

@Service
@RequiredArgsConstructor
public class PasswordResetServiceImpl implements PasswordResetService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final MailService mailService;
    private final StringRedisTemplate redis;
    private final ObjectMapper objectMapper = new ObjectMapper();


    @Override
    public void requestReset(String email) {

        // 1. Email var mı kontrol
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("Email not found."));

        // 2. 6 haneli kod üret
        String code = generate6DigitCode();

        // 3. Redis’e kaydet
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

        // 4. Mail gönder
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

            // 1. Yeni şifreyi hashleyip kaydet
            user.setPassword(passwordEncoder.encode(newPassword));
            userRepository.save(user);

            // 2. used = true yap
            data.put("used", true);

            redis.opsForValue().set(key,
                    objectMapper.writeValueAsString(data),
                    1, TimeUnit.MINUTES);

            // 3. tamamen sil
            redis.delete(key);

        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }



    private String generate6DigitCode() {
        Random r = new Random();
        return String.format("%06d", r.nextInt(999999));
    }
}

