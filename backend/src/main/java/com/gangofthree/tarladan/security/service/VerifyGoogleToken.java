package com.gangofthree.tarladan.security.service;

import com.gangofthree.tarladan.shared.dto.GoogleUserResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

/**
 * Google authentication service (the interrogator).
 * * This class verifies the "ID Token" the frontend (React/Flutter) received from Google
 * by asking Google's own servers whether it's genuine.
 * * It exists to eliminate the "the frontend sent me a token, but is it real?" doubt.
 */
@Service // @Service (rather than @Component) fits better for business-logic classes.
public class VerifyGoogleToken {

    private static final Logger log = LoggerFactory.getLogger(VerifyGoogleToken.class);

    // Google's token verification endpoint. %s is replaced with the incoming token.
    private static final String GOOGLE_TOKEN_INFO_URL =
            "https://oauth2.googleapis.com/tokeninfo?id_token=%s";

    private final RestTemplate restTemplate;

    public VerifyGoogleToken(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    /**
     * Verify a Google ID token.
     * @param idToken the long JWT string from the frontend (Google ID Token)
     * @return GoogleUserResponse (email, name, and picture returned by Google)
     */
    public GoogleUserResponse verify(String idToken) {
        String url = String.format(GOOGLE_TOKEN_INFO_URL, idToken);

        ResponseEntity<GoogleUserResponse> response;

        try {
            // 1. Ask Google via GET ("is this token valid?").
            // 2. Deserialize the response body into our GoogleUserResponse DTO.
            response = restTemplate.getForEntity(url, GoogleUserResponse.class);
        } catch (Exception ex) {
            // Google was unreachable, or the token format was malformed.
            log.error("Google token verification request failed", ex);
            throw new RuntimeException("Google token doğrulama isteği başarısız oldu: " + ex.getMessage());
        }

        // Google returns a non-2xx status for an expired or forged token.
        if (!response.getStatusCode().is2xxSuccessful() || response.getBody() == null) {
            // Authentication failure, not a server error: map to 403 via GlobalExceptionHandler.
            throw new SecurityException("Geçersiz Google ID Token. Kimlik doğrulanamadı.");
        }

        // All good — return the user info (email, name, etc.) from Google.
        return response.getBody();
    }
}
