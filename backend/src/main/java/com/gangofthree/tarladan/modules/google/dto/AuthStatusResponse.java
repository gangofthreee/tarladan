package com.gangofthree.tarladan.modules.google.dto;

import com.gangofthree.tarladan.common.dto.TokenResponse;
import lombok.*;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class AuthStatusResponse {

    // Eğer 'true' ise, kullanıcı sistemde kayıtlıdır, direkt login yapılır.
    // Eğer 'false' ise, kullanıcı yeni demektir ve role/phone bilgileri istenmelidir.
    private boolean isRegistered;
    private TokenResponse tokenResponse;
}