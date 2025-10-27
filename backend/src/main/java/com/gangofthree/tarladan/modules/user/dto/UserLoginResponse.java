package com.gangofthree.tarladan.modules.user.dto;

import com.gangofthree.tarladan.common.enums.UserRole;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserLoginResponse {
    private Long id;
    private String name;
    private String surname;
    private String email;
    private String phone;
    private UserRole role;
}

