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
import com.gangofthree.tarladan.modules.user.repository.UserRepository;
import com.gangofthree.tarladan.modules.depotOwner.repository.DepotOwnerRepository;
import com.gangofthree.tarladan.modules.farmer.repository.FarmerRepository;
import com.gangofthree.tarladan.modules.trucker.repository.TruckerRepository;

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
    private final RoleBasedIdService roleBasedIdService;
    private final FarmerRepository farmerRepository;
    private final DepotOwnerRepository depotOwnerRepository;
    private final CustomerRepository customerRepository;
    private final TruckerRepository truckerRepository;

    @Override
    public AuthStatusResponse verifyStatus(GoogleAuthRequest request) {
        GoogleUserResponse googleUserResponse = verifyGoogleToken.verify(request.getIdToken());
        Optional<User> existingUser = googleRepository.findByEmail(googleUserResponse.getEmail());
        User user;
        if (existingUser.isPresent()) { // kullanici kayitli
            user = existingUser.get();

            if (!user.isGoogleVerified()) { //isGoogleVerified false ise simdi true yap
                user.setGoogleVerified(true);
                user = googleRepository.save(user);
            }

            TokenResponse tokenResponse = createTokenResponse(user); //token olustur
            return new AuthStatusResponse(true, tokenResponse);
        }else {
            return new AuthStatusResponse(false, null); //kullanici yok, token yok
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

        Long domainId = roleBasedIdService.getDomainId(user);// RoleBasedId için varsayılan değer

        // 1. Access Token üret
        String accessToken = jwtUtil.generateAccessToken(user.getId(), roleString, domainId);

        // 2. Access Token'ı Redis'e kaydet (ÖNEMLİ!)
        tokenService.saveAccessToken(user.getId(), accessToken);

        // 3. Refresh Token üret/güncelle
        String refreshToken = tokenService.createOrUpdateRefreshToken(user.getId(), domainId, accessToken);

        // 4. TokenResponse DTO'sunu oluştur
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
            finalRole = UserRole.valueOf(desiredRole.toUpperCase());//enum karsilastirma
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