package com.gangofthree.tarladan.modules.google.dto;

import com.gangofthree.tarladan.shared.dto.TokenResponse;
import lombok.*;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class AuthStatusResponse {

    // If 'true', the user is already registered and has been logged in directly.
    // If 'false', the user is new and their role/phone information must be requested.
    private boolean isRegistered;
    private TokenResponse tokenResponse;
}