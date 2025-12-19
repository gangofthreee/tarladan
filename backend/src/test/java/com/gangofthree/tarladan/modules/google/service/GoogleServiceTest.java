package com.gangofthree.tarladan.modules.google.service;

import com.gangofthree.tarladan.modules.google.dto.AuthStatusResponse;
import com.gangofthree.tarladan.modules.google.dto.GoogleAuthRequest;
import com.gangofthree.tarladan.modules.google.repository.GoogleRepository;
import com.gangofthree.tarladan.modules.user.entity.User;
import com.gangofthree.tarladan.modules.user.service.RoleBasedIdService;
import com.gangofthree.tarladan.security.jwt.JwtUtil;
import com.gangofthree.tarladan.security.service.TokenService;
import com.gangofthree.tarladan.security.service.VerifyGoogleToken;
import com.gangofthree.tarladan.shared.dto.GoogleUserResponse;
import com.gangofthree.tarladan.shared.enums.UserRole;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class GoogleServiceTest {

    @Mock
    private GoogleRepository googleRepository;
    @Mock
    private VerifyGoogleToken verifyGoogleToken;
    @Mock
    private JwtUtil jwtUtil;
    @Mock
    private TokenService tokenService;
    @Mock
    private RoleBasedIdService roleBasedIdService;

    @InjectMocks
    private GoogleServiceImpl googleService;

    @Test
    void whenVerifyStatusAndUserExists_thenReturnsTrueAndToken() {
        // Arrange
        GoogleAuthRequest request = new GoogleAuthRequest();
        request.setIdToken("dummyToken");
        
        GoogleUserResponse googleUserResponse = GoogleUserResponse.builder()
                .email("test@example.com")
                .name("Test User")
                .picture("pictureUrl")
                .build();
        
        User user = User.builder().id(1L).email("test@example.com").role(UserRole.FARMER).isGoogleVerified(true).build();

        when(verifyGoogleToken.verify("dummyToken")).thenReturn(googleUserResponse);
        when(googleRepository.findByEmail("test@example.com")).thenReturn(Optional.of(user));
        when(roleBasedIdService.getDomainId(user)).thenReturn(10L);
        when(jwtUtil.generateAccessToken(1L, "FARMER", 10L)).thenReturn("accessToken");
        when(tokenService.createOrUpdateRefreshToken(1L, 10L, "accessToken")).thenReturn("refreshToken");

        // Act
        AuthStatusResponse response = googleService.verifyStatus(request);

        // Assert
        assertThat(response.isRegistered()).isTrue();
        assertThat(response.getTokenResponse()).isNotNull();
        assertThat(response.getTokenResponse().getAccessToken()).isEqualTo("accessToken");
    }

    @Test
    void whenVerifyStatusAndUserDoesNotExist_thenReturnsFalse() {
        // Arrange
        GoogleAuthRequest request = new GoogleAuthRequest();
        request.setIdToken("dummyToken");
        
        GoogleUserResponse googleUserResponse = GoogleUserResponse.builder()
                .email("new@example.com")
                .name("New User")
                .picture("pictureUrl")
                .build();

        when(verifyGoogleToken.verify("dummyToken")).thenReturn(googleUserResponse);
        when(googleRepository.findByEmail("new@example.com")).thenReturn(Optional.empty());

        // Act
        AuthStatusResponse response = googleService.verifyStatus(request);

        // Assert
        assertThat(response.isRegistered()).isFalse();
        assertThat(response.getTokenResponse()).isNull();
    }
}
