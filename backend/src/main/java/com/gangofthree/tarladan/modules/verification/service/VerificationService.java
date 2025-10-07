package com.gangofthree.tarladan.modules.verification.service;

import com.gangofthree.tarladan.common.utils.MailService;
import com.gangofthree.tarladan.common.utils.RedisService;
import com.gangofthree.tarladan.modules.user.dto.VerifyCodeRequest;
import com.gangofthree.tarladan.modules.user.entity.User;
import com.gangofthree.tarladan.modules.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.security.SecureRandom;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class VerificationService {

    private final RedisService redisService;
    private final MailService mailService;
    private final UserRepository userRepository;

    public void sendCode(User user) {
        String code = generateCode();
        redisService.saveVerificationCode(user.getEmail(), code);
        mailService.sendVerificationCode(user.getEmail(), code);
    }

    public boolean verifyCode(VerifyCodeRequest request) {
        String email = request.getEmail();
        String storedCode = redisService.getVerificationCode(email);

        if (storedCode == null) {
            return false; // Kod hiç bulunamadı (expire olmuş ya da hiç gönderilmemiş)
        }

        if (!storedCode.equals(request.getVerificationCode())) {
            // Yanlış kod → redis’ten sil, kullanıcı kaydını da sil
            userRepository.deleteByEmail(email);
            redisService.deleteCode(email);
            return false;
        }

        // ✅ Kod doğru → kullanıcı mailVerified = true yapılır
        Optional<User> userOpt = userRepository.findByEmail(email);
        if (userOpt.isPresent()) {
            User user = userOpt.get();
            user.setMailVerified(true);
            userRepository.save(user);
        }

        // Kullanılan kodu temizle
        redisService.deleteCode(email);
        return true;
    }

    public void resendCode(String email) {
        Optional<User> userOpt = userRepository.findByEmail(email);
        if (userOpt.isPresent()) {
            sendCode(userOpt.get());
        }
    }

    private String generateCode() {
        SecureRandom random = new SecureRandom();
        int number = 100000 + random.nextInt(900000);
        return String.valueOf(number);
    }
}

