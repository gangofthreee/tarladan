package com.gangofthree.tarladan.modules.user.dto;

import com.gangofthree.tarladan.shared.enums.UserRole;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class UserProfileResponse {
    private Long id;
    private String name;
    private String surname;
    private String email;
    private String phone;
    private UserRole role;
    private boolean isMailVerified;
}
