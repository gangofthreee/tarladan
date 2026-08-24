package com.gangofthree.tarladan.modules.passwordReset.service;

import com.gangofthree.tarladan.infrastructure.mail.MailService;
import com.gangofthree.tarladan.modules.user.entity.User;
import com.gangofthree.tarladan.modules.user.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.ValueOperations;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Optional;
import java.util.concurrent.TimeUnit;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class PasswordResetServiceTest {

    @Mock
    private UserRepository userRepository;
    @Mock
    private PasswordEncoder passwordEncoder;
    @Mock
    private MailService mailService;
    @Mock
    private StringRedisTemplate redisTemplate;
    @Mock
    private ValueOperations<String, String> valueOperations;

    private PasswordResetServiceImpl passwordResetService;

    @BeforeEach
    void setUp() {
        passwordResetService = new PasswordResetServiceImpl(userRepository, passwordEncoder, mailService, redisTemplate);
    }

    @Test
    void whenRequestReset_withKnownEmail_thenCodeIsStoredInRedisAndEmailIsSent() {
        String email = "test@example.com";
        User user = User.builder().id(1L).email(email).build();
        when(userRepository.findByEmail(email)).thenReturn(Optional.of(user));
        when(redisTemplate.opsForValue()).thenReturn(valueOperations);

        passwordResetService.requestReset(email);

        ArgumentCaptor<String> keyCaptor = ArgumentCaptor.forClass(String.class);
        verify(valueOperations).set(keyCaptor.capture(), anyString(), eq(3L), eq(TimeUnit.MINUTES));
        assertThat(keyCaptor.getValue()).startsWith("password-reset:");

        ArgumentCaptor<String> codeCaptor = ArgumentCaptor.forClass(String.class);
        verify(mailService).sendResetCode(eq(email), codeCaptor.capture());
        assertThat(codeCaptor.getValue()).matches("\\d{6}");
    }

    @Test
    void whenRequestReset_withUnknownEmail_thenReturnsSilentlyAndNoEmailIsSent() {
        // No exception and no distinguishable response for an unknown email, by design:
        // this prevents callers from enumerating registered addresses via this endpoint.
        String email = "missing@example.com";
        when(userRepository.findByEmail(email)).thenReturn(Optional.empty());

        assertDoesNotThrow(() -> passwordResetService.requestReset(email));
        verifyNoInteractions(mailService);
    }

    @Test
    void whenConfirmCode_withValidCode_thenMarksCodeAsVerifiedInRedis() {
        String code = "123456";
        String key = "password-reset:" + code;
        String storedJson = "{\"email\":\"test@example.com\",\"resetCode\":\"123456\",\"verified\":false,\"used\":false}";
        when(redisTemplate.opsForValue()).thenReturn(valueOperations);
        when(valueOperations.get(key)).thenReturn(storedJson);

        passwordResetService.confirmCode(code);

        ArgumentCaptor<String> jsonCaptor = ArgumentCaptor.forClass(String.class);
        verify(valueOperations).set(eq(key), jsonCaptor.capture(), eq(3L), eq(TimeUnit.MINUTES));
        assertThat(jsonCaptor.getValue()).contains("\"verified\":true");
    }

    @Test
    void whenConfirmCode_withUnknownCode_thenThrows() {
        String code = "000000";
        when(redisTemplate.opsForValue()).thenReturn(valueOperations);
        when(valueOperations.get("password-reset:" + code)).thenReturn(null);

        assertThrows(IllegalArgumentException.class, () -> passwordResetService.confirmCode(code));
    }

    @Test
    void whenSetNewPassword_withVerifiedUnusedCode_thenPasswordIsUpdatedAndCodeDeleted() {
        String code = "123456";
        String key = "password-reset:" + code;
        String email = "test@example.com";
        String storedJson = "{\"email\":\"" + email + "\",\"resetCode\":\"123456\",\"verified\":true,\"used\":false}";
        User user = User.builder().id(1L).email(email).build();

        when(redisTemplate.opsForValue()).thenReturn(valueOperations);
        when(valueOperations.get(key)).thenReturn(storedJson);
        when(userRepository.findByEmail(email)).thenReturn(Optional.of(user));
        when(passwordEncoder.encode("newPassword")).thenReturn("hashedPassword");

        passwordResetService.setNewPassword(code, "newPassword");

        assertThat(user.getPassword()).isEqualTo("hashedPassword");
        verify(userRepository).save(user);
        verify(redisTemplate).delete(key);
    }

    @Test
    void whenSetNewPassword_withUnverifiedCode_thenThrowsAndPasswordIsNotChanged() {
        String code = "123456";
        String key = "password-reset:" + code;
        String storedJson = "{\"email\":\"test@example.com\",\"resetCode\":\"123456\",\"verified\":false,\"used\":false}";

        when(redisTemplate.opsForValue()).thenReturn(valueOperations);
        when(valueOperations.get(key)).thenReturn(storedJson);

        assertThrows(RuntimeException.class, () -> passwordResetService.setNewPassword(code, "newPassword"));
        verify(userRepository, never()).save(any());
    }
}
