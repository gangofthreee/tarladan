package com.gangofthree.tarladan.modules.google.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class GoogleRegisterRequest {

    @NotBlank(message = "ID Token boş olamaz.")
    private String idToken;


    @NotBlank(message = "Rol bilgisi zorunludur.")
    private String desiredRole;

    @NotBlank(message = "Telefon numarası zorunludur.")
    @Pattern(regexp = "^\\d{10,15}$", message = "Geçersiz telefon formatı.")
    private String phone;
}