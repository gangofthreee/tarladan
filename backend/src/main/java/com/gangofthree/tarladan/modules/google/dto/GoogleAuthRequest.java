package com.gangofthree.tarladan.modules.google.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class GoogleAuthRequest {

    @NotBlank(message = "ID Token boş olamaz.")
    private String idToken;
}

