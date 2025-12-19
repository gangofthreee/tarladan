package com.gangofthree.tarladan.modules.passwordReset.service;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.mockito.Mockito.verify;

@ExtendWith(MockitoExtension.class)
class PasswordResetServiceTest {

    @Mock
    private PasswordResetService passwordResetService;

    @Test
    void testRequestReset() {
        String email = "test@example.com";
        passwordResetService.requestReset(email);
        verify(passwordResetService).requestReset(email);
    }

    @Test
    void testConfirmCode() {
        String code = "123456";
        passwordResetService.confirmCode(code);
        verify(passwordResetService).confirmCode(code);
    }

    @Test
    void testSetNewPassword() {
        String code = "123456";
        String newPassword = "newPassword";
        passwordResetService.setNewPassword(code, newPassword);
        verify(passwordResetService).setNewPassword(code, newPassword);
    }
}
