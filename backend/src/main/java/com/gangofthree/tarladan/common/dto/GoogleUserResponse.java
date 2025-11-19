package com.gangofthree.tarladan.common.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class GoogleUserResponse {

    private String email;

    @JsonProperty("given_name")
    private String name;

    @JsonProperty("family_name")
    private String surname;
    private String picture;

    @JsonProperty("email_verified")
    private String emailVerified;
}
