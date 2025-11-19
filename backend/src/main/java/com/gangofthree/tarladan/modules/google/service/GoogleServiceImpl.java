package com.gangofthree.tarladan.modules.google.service;

import com.gangofthree.tarladan.common.dto.GoogleUserResponse;
import com.gangofthree.tarladan.common.dto.TokenResponse;
import com.gangofthree.tarladan.common.enums.UserRole;
import com.gangofthree.tarladan.common.utils.JwtUtil;
import com.gangofthree.tarladan.common.utils.VerifyGoogleToken;
import com.gangofthree.tarladan.core.service.TokenService;
import com.gangofthree.tarladan.modules.google.dto.AuthStatusResponse;
import com.gangofthree.tarladan.modules.google.dto.GoogleAuthRequest;
import com.gangofthree.tarladan.modules.google.dto.GoogleRegisterRequest;
import com.gangofthree.tarladan.modules.google.repository.GoogleRepository;
import com.gangofthree.tarladan.modules.user.entity.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;



import java.util.Optional;

@Service
@RequiredArgsConstructor
public class GoogleServiceImpl implements GoogleService {

    private final GoogleRepository googleRepository;
    private final VerifyGoogleToken verifyGoogleToken;
    private final JwtUtil jwtUtil;
    private final TokenService tokenService;

    @Override
    public AuthStatusResponse verifyStatus(GoogleAuthRequest request) {
        GoogleUserResponse googleUserResponse = verifyGoogleToken.verify(request.getIdToken());
        Optional<User> existingUser = googleRepository.findByEmail(googleUserResponse.getEmail());
        User user;
        if (existingUser.isPresent()) {
            user = existingUser.get();

            if (!user.isGoogleVerified()) {
                user.setGoogleVerified(true);
                user = googleRepository.save(user);
            }

            TokenResponse tokenResponse = createTokenResponse(user);
            return new AuthStatusResponse(true, tokenResponse);
        }else {
            return new AuthStatusResponse(false, null);
        }
    }

    @Override
    @Transactional
    public TokenResponse processAuth(GoogleRegisterRequest request){
        GoogleUserResponse googleUserResponse = verifyGoogleToken.verify(request.getIdToken());
        System.out.println(googleUserResponse);

        User user = registerNewGoogleUser(googleUserResponse, request.getDesiredRole(), request.getPhone());

        return createTokenResponse(user);
    }

    private TokenResponse createTokenResponse(User user) {

        String roleString = user.getRole().name();
        Long domainId = 0L; // RoleBasedId için varsayılan değer

        // 1. Access Token üret
        String accessToken = jwtUtil.generateAccessToken(user.getId(), roleString, domainId);

        // 2. Refresh Token üret/güncelle
        String refreshToken = tokenService.createOrUpdateRefreshToken(user.getId(), domainId, accessToken);

        // 3. TokenResponse DTO'sunu oluştur
        return TokenResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .userId(user.getId())
                .role(user.getRole())
                .roleBasedId(domainId)
                .message("Google ile başarılı giriş/kayıt.")
                .build();
    }

    private User registerNewGoogleUser(GoogleUserResponse googleInfo, String desiredRole, String phone) {
        UserRole finalRole;
        try {
            finalRole = UserRole.valueOf(desiredRole.toUpperCase());
        } catch (IllegalArgumentException e) {
            throw new RuntimeException("Geçersiz veya desteklenmeyen kullanıcı rolü: " + desiredRole);
        }

        User user = User.builder()
                .email(googleInfo.getEmail())
                .name(googleInfo.getName())
                .surname(googleInfo.getSurname())
                .password("GOOGLE_AUTH_PLACEHOLDER")
                .phone(phone)
                .role(finalRole)
                .isMailVerified(true)
                .isGoogleVerified(true)
                .isPhoneVerified(false)
                .build();

        return googleRepository.save(user);
    }
}
