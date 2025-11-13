package com.gangofthree.tarladan.common.dto;

import com.gangofthree.tarladan.common.enums.UserRole;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class TokenResponse {
    private String accessToken;
    private String refreshToken;
    private Long userId;
    private UserRole role;
    private Long roleBasedId; // FarmerId, CustomerId vb.
    private String message;
}
