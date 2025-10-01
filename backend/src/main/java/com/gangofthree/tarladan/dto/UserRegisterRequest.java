package com.gangofthree.tarladan.dto;

import com.gangofthree.tarladan.enums.UserRole;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class UserRegisterRequest {
    private String name;
    private String surname;
    private String phone;
    private String email;
    private String password;
    private UserRole role;
    private boolean isMailVerified = false;
    private boolean isPhoneVerified = false;
    private boolean isGoogleVerified = false;
}

