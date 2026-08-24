package com.gangofthree.tarladan.modules.verification.service;

import com.gangofthree.tarladan.infrastructure.mail.MailService;
import com.gangofthree.tarladan.infrastructure.redis.RedisService;
import com.gangofthree.tarladan.modules.user.dto.VerifyCodeRequest;
import com.gangofthree.tarladan.modules.user.entity.User;
import com.gangofthree.tarladan.modules.user.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class VerificationServiceTest {

    @Mock
    private RedisService redisService;
    @Mock
    private MailService mailService;
    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private VerificationService verificationService;

    @Test
    void whenSendCode_thenCodeIsGeneratedAndSavedAndSent() {
        User user = User.builder().email("test@example.com").build();

        verificationService.sendCode(user);

        verify(redisService).saveVerificationCode(eq("test@example.com"), anyString());
        verify(mailService).sendVerificationCode(eq("test@example.com"), anyString());
    }

    @Test
    void whenVerifyCodeIsCorrect_thenUserIsVerified() {
        VerifyCodeRequest request = new VerifyCodeRequest();
        request.setEmail("test@example.com");
        request.setVerificationCode("123456");

        User user = User.builder().email("test@example.com").isMailVerified(false).build();

        when(redisService.getVerificationCode("test@example.com")).thenReturn("123456");
        when(userRepository.findByEmail("test@example.com")).thenReturn(Optional.of(user));

        boolean result = verificationService.verifyCode(request);

        assertThat(result).isTrue();
        assertThat(user.isMailVerified()).isTrue();
        verify(userRepository).save(user);
    }

    @Test
    void whenVerifyCodeIsIncorrect_thenRejectedAndAccountAndCodeAreKept() {
        // A wrong code must not destroy the account or consume the stored code,
        // otherwise a single typo (or one unauthenticated guess) would permanently
        // lock the user out of an unverified account.
        VerifyCodeRequest request = new VerifyCodeRequest();
        request.setEmail("test@example.com");
        request.setVerificationCode("wrongCode");

        when(redisService.getVerificationCode("test@example.com")).thenReturn("123456");

        boolean result = verificationService.verifyCode(request);

        assertThat(result).isFalse();
        verify(userRepository, never()).deleteByEmail(anyString());
        verify(redisService, never()).deleteCode(anyString());
    }
}
