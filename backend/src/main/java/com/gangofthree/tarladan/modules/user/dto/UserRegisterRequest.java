package com.gangofthree.tarladan.modules.user.dto;

import com.gangofthree.tarladan.shared.enums.UserRole;
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
}

