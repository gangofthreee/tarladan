package com.gangofthree.tarladan.modules.verification.service;

import com.gangofthree.tarladan.infrastructure.mail.MailService;
import com.gangofthree.tarladan.infrastructure.redis.RedisService;
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
            return false; // No code found (expired or never sent)
        }

        if (!storedCode.equals(request.getVerificationCode())) {
            // Wrong code: just reject, keep the code and the user account intact so the user can retry.
            return false;
        }

        // Code correct: mark the user as mail verified
        Optional<User> userOpt = userRepository.findByEmail(email);
        if (userOpt.isPresent()) {
            User user = userOpt.get();
            user.setMailVerified(true);
            userRepository.save(user);
        }

        // Clear the used code so it cannot be replayed
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

