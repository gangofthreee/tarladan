package com.gangofthree.tarladan.modules.google.service;

import com.gangofthree.tarladan.modules.customer.entity.Customer;
import com.gangofthree.tarladan.modules.customer.repository.CustomerRepository;
import com.gangofthree.tarladan.modules.depotOwner.entity.DepotOwner;
import com.gangofthree.tarladan.modules.farmer.entity.Farmer;
import com.gangofthree.tarladan.modules.trucker.entity.Trucker;
import com.gangofthree.tarladan.modules.user.service.RoleBasedIdService;
import com.gangofthree.tarladan.shared.dto.GoogleUserResponse;
import com.gangofthree.tarladan.shared.dto.TokenResponse;
import com.gangofthree.tarladan.shared.enums.UserRole;
import com.gangofthree.tarladan.security.jwt.JwtUtil;
import com.gangofthree.tarladan.security.service.VerifyGoogleToken;
import com.gangofthree.tarladan.security.service.TokenService;
import com.gangofthree.tarladan.modules.google.dto.AuthStatusResponse;
import com.gangofthree.tarladan.modules.google.dto.GoogleAuthRequest;
import com.gangofthree.tarladan.modules.google.dto.GoogleRegisterRequest;
import com.gangofthree.tarladan.modules.google.repository.GoogleRepository;
import com.gangofthree.tarladan.modules.user.entity.User;
import com.gangofthree.tarladan.modules.depotOwner.repository.DepotOwnerRepository;
import com.gangofthree.tarladan.modules.farmer.repository.FarmerRepository;
import com.gangofthree.tarladan.modules.trucker.repository.TruckerRepository;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;



import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class GoogleServiceImpl implements GoogleService {

    private final GoogleRepository googleRepository;
    private final VerifyGoogleToken verifyGoogleToken;
    private final JwtUtil jwtUtil;
    private final TokenService tokenService;
    private final RoleBasedIdService roleBasedIdService;
    private final FarmerRepository farmerRepository;
    private final DepotOwnerRepository depotOwnerRepository;
    private final CustomerRepository customerRepository;
    private final TruckerRepository truckerRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public AuthStatusResponse verifyStatus(GoogleAuthRequest request) {
        GoogleUserResponse googleUserResponse = verifyGoogleToken.verify(request.getIdToken());
        Optional<User> existingUser = googleRepository.findByEmail(googleUserResponse.getEmail());
        User user;
        if (existingUser.isPresent()) { // user already registered
            user = linkExistingUserToGoogle(existingUser.get());

            TokenResponse tokenResponse = createTokenResponse(user); // issue tokens
            return new AuthStatusResponse(true, tokenResponse);
        }else {
            return new AuthStatusResponse(false, null); // user does not exist yet, no tokens
        }
    }

    @Override
    @Transactional
    public TokenResponse processAuth(GoogleRegisterRequest request){
        GoogleUserResponse googleUserResponse = verifyGoogleToken.verify(request.getIdToken());
        log.debug("Google auth verified for email: {}", googleUserResponse.getEmail());

        // A client could call this endpoint for an email that is already registered
        // (e.g. it skipped /verify-status, or the account was created in the meantime).
        // Guard against that instead of hitting the unique constraint on email/phone.
        Optional<User> existingUser = googleRepository.findByEmail(googleUserResponse.getEmail());
        User user = existingUser.isPresent()
                ? linkExistingUserToGoogle(existingUser.get())
                : registerNewGoogleUser(googleUserResponse, request.getDesiredRole(), request.getPhone());

        return createTokenResponse(user);
    }

    private User linkExistingUserToGoogle(User user) {
        if (!user.isGoogleVerified()) {
            user.setGoogleVerified(true);
            user = googleRepository.save(user);
        }
        return user;
    }

    private TokenResponse createTokenResponse(User user) {

        String roleString = user.getRole().name();

        Long domainId = roleBasedIdService.getDomainId(user);

        // 1. Generate the access token
        String accessToken = jwtUtil.generateAccessToken(user.getId(), roleString, domainId);

        // 2. Store the access token in Redis (tracks the active session)
        tokenService.saveAccessToken(user.getId(), accessToken);

        // 3. Generate/refresh the refresh token
        String refreshToken = tokenService.createOrUpdateRefreshToken(user.getId(), domainId, accessToken);

        // 4. Build the TokenResponse DTO
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
            finalRole = UserRole.valueOf(desiredRole.toUpperCase()); // case-insensitive enum match
        } catch (IllegalArgumentException e) {
            throw new RuntimeException("Geçersiz veya desteklenmeyen kullanıcı rolü: " + desiredRole);
        }

        // Google-authenticated accounts never log in with a password, but the column is
        // NOT NULL, so store an unguessable, already-hashed value rather than a fixed
        // literal (which would otherwise be a predictable, shared "password" for every
        // Google account).
        String unusablePassword = passwordEncoder.encode(UUID.randomUUID().toString());

        User user = User.builder()
                .email(googleInfo.getEmail())
                .name(googleInfo.getName())
                .surname(googleInfo.getSurname())
                .password(unusablePassword)
                .phone(phone)
                .role(finalRole)
                .isMailVerified(true)
                .isGoogleVerified(true)
                .isPhoneVerified(false)
                .build();

        User savedUser =  googleRepository.save(user);

        switch (finalRole) {
            case FARMER -> {
                Farmer farmer = Farmer.builder().user(savedUser).build();
                farmerRepository.save(farmer);
            }
            case DEPOT_OWNER -> {
                DepotOwner depotOwner = DepotOwner.builder().user(savedUser).build();
                depotOwnerRepository.save(depotOwner);
            }
            case CUSTOMER -> {
                Customer customer = Customer.builder().user(savedUser).build();
                customerRepository.save(customer);
            }
            case TRUCKER -> {
                Trucker trucker = Trucker.builder().user(savedUser).build();
                truckerRepository.save(trucker);
            }
        }
        return savedUser;
    }
    }