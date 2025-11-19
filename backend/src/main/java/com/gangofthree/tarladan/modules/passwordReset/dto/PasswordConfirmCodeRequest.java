package com.gangofthree.tarladan.modules.passwordReset.dto;

import lombok.Data;

@Data
public class PasswordConfirmCodeRequest {
    private String resetCode;
}

