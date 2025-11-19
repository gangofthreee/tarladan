package com.gangofthree.tarladan.common.utils;

import com.gangofthree.tarladan.common.dto.GoogleUserResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

@Component
public class VerifyGoogleToken {

    private static final String GOOGLE_TOKEN_INFO_URL =
            "https://oauth2.googleapis.com/tokeninfo?id_token=%s";

    public GoogleUserResponse verify(String idToken){
        RestTemplate restTemplate = new RestTemplate();

        String url = String.format(GOOGLE_TOKEN_INFO_URL, idToken);

        ResponseEntity<GoogleUserResponse> response;

        try {
            response = restTemplate.getForEntity(url, GoogleUserResponse.class);
        } catch (Exception ex) {
            throw new RuntimeException("Google token doğrulama isteği başarısız.");
        }

        if (!response.getStatusCode().is2xxSuccessful() || response.getBody() == null) {
            throw new RuntimeException("Geçersiz Google ID Token.");
        }

        return response.getBody();
    }
}
