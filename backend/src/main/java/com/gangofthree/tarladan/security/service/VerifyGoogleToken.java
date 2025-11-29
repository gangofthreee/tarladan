package com.gangofthree.tarladan.security.service;

import com.gangofthree.tarladan.shared.dto.GoogleUserResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

/**
 * Google Kimlik Doğrulama Servisi (The Interrogator)
 * * Bu sınıf, Frontend'in (React/Flutter) Google'dan aldığı "ID Token"ın
 * geçerliliğini, doğrudan Google sunucularına sorarak doğrular.
 * * "Frontend bana bir token yolladı ama belki de o token sahte?" şüphesini
 * ortadan kaldırmak için kullanılır.
 */
@Service // @Component yerine @Service kullanmak iş mantığı için daha uygundur.
public class VerifyGoogleToken {

    // Google'ın token doğrulama endpoint'i.
    // %s yerine gelen token'ı yapıştıracağız.
    private static final String GOOGLE_TOKEN_INFO_URL =
            "https://oauth2.googleapis.com/tokeninfo?id_token=%s";

    /**
     * Google ID Token'ı Doğrula
     * @param idToken Frontend'den gelen upuzun JWT string (Google ID Token)
     * @return GoogleUserResponse (Google'dan dönen email, isim, resim bilgileri)
     */
    public GoogleUserResponse verify(String idToken) {
        // RestTemplate: Spring'in dış dünyaya HTTP isteği (GET/POST) atmak için kullandığı araçtır.
        // Not: Best Practice olarak bunu her seferinde 'new'lemek yerine Bean olarak inject etmek daha iyidir.
        RestTemplate restTemplate = new RestTemplate();

        // URL'i oluştur: https://oauth2....?id_token=eyJhbGci...
        String url = String.format(GOOGLE_TOKEN_INFO_URL, idToken);

        ResponseEntity<GoogleUserResponse> response;

        try {
            // 1. Google'a GET isteği at ("Bu token geçerli mi?")
            // 2. Gelen cevabı GoogleUserResponse sınıfına (DTO) çevir.
            response = restTemplate.getForEntity(url, GoogleUserResponse.class);
        } catch (Exception ex) {
            // Google sunucularına ulaşılamazsa veya token formatı bozuksa burası çalışır.
            throw new RuntimeException("Google token doğrulama isteği başarısız oldu: " + ex.getMessage());
        }

        // Token süresi dolmuşsa veya sahteyse Google hata kodu döner.
        // HTTP 200 (OK) dönmediyse veya body boşsa token geçersizdir.
        if (!response.getStatusCode().is2xxSuccessful() || response.getBody() == null) {
            throw new RuntimeException("Geçersiz Google ID Token. Kimlik doğrulanamadı.");
        }

        // Her şey yolunda, Google'dan gelen kullanıcı bilgilerini (Email, İsim vb.) dön.
        return response.getBody();
    }
}