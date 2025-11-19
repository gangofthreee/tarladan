package com.gangofthree.tarladan.modules.passwordReset.service;

public interface PasswordResetService {
    void requestReset(String email);
    void confirmCode(String resetCode);
    void setNewPassword(String resetCode, String newPassword);
}

