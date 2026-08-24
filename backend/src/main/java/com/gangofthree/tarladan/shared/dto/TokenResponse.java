package com.gangofthree.tarladan.shared.dto;

import com.gangofthree.tarladan.shared.enums.UserRole;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class TokenResponse {
    private String accessToken;
    private String refreshToken;
    private Long userId;
    private UserRole role;
    private Long roleBasedId; // FarmerId, CustomerId, etc.
    private String message;
}
