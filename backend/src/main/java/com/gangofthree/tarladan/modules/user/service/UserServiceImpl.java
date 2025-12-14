package com.gangofthree.tarladan.modules.user.service;

import com.gangofthree.tarladan.modules.user.dto.UserProfileResponse;
import com.gangofthree.tarladan.shared.dto.TokenResponse;
import com.gangofthree.tarladan.security.jwt.JwtUtil;
import com.gangofthree.tarladan.security.service.TokenService;
import com.gangofthree.tarladan.modules.customer.entity.Customer;
import com.gangofthree.tarladan.modules.customer.repository.CustomerRepository;
import com.gangofthree.tarladan.modules.trucker.entity.Trucker;
import com.gangofthree.tarladan.modules.trucker.repository.TruckerRepository;
import com.gangofthree.tarladan.modules.user.dto.UserLoginRequest;
import com.gangofthree.tarladan.modules.user.dto.UserRegisterRequest;
import com.gangofthree.tarladan.modules.depotOwner.entity.DepotOwner;
import com.gangofthree.tarladan.modules.farmer.entity.Farmer;
import com.gangofthree.tarladan.modules.user.entity.User;
import com.gangofthree.tarladan.shared.enums.UserRole;
import com.gangofthree.tarladan.modules.user.repository.UserRepository;
import com.gangofthree.tarladan.modules.depotOwner.repository.DepotOwnerRepository;
import com.gangofthree.tarladan.modules.farmer.repository.FarmerRepository;
import com.gangofthree.tarladan.modules.verification.service.VerificationService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final VerificationService verificationService;
    private final JwtUtil jwtUtil;
    private final TokenService tokenService;
    private final RoleBasedIdService roleBasedIdService;
    private final FarmerRepository farmerRepository;
    private final DepotOwnerRepository depotOwnerRepository;
    private final CustomerRepository customerRepository;
    private final TruckerRepository truckerRepository;

    @Override
    @Transactional
    public User register(UserRegisterRequest request) {
        // email & phone kontrolü
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new IllegalArgumentException("Email already in use");
        }
        if (userRepository.existsByPhone(request.getPhone())) {
            throw new IllegalArgumentException("Phone already in use");
        }

        String roleString = String.valueOf(request.getRole()); // null olsa bile "null" string olur
        UserRole userRole;
        try {
            userRole = UserRole.valueOf(roleString.toUpperCase()); // büyük harf ile enum karşılaştırması
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("Invalid role provided: " + roleString);
        }


        // Password Hashleme
        String encodedPassword = passwordEncoder.encode(request.getPassword());

        User user = User.builder()
                .name(request.getName())
                .surname(request.getSurname())
                .phone(request.getPhone())
                .email(request.getEmail())
                .password(encodedPassword)
                .role(request.getRole())
                .isMailVerified(false)
                .isGoogleVerified(false)
                .isPhoneVerified(false)
                .build();

        User savedUser = userRepository.save(user);

        // Role göre ilgili tabloya kaydet
        switch (userRole) {
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

        verificationService.sendCode(savedUser);

        return savedUser;
    }

    @Override
    @Transactional
    public TokenResponse login(UserLoginRequest request) {
        // Email’e göre kullanıcıyı bul
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new IllegalArgumentException("User not found with email: " + request.getEmail()));

        // Şifre kontrolü
        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new IllegalArgumentException("Invalid password");
        }

        // E-posta doğrulama kontrolü (opsiyonel)
        if (!user.isMailVerified()) {
            throw new IllegalArgumentException("Email is not verified");
        }

        // 1. Role bağlı domain ID'yi al (farmerId, truckerId, vb.)
        Long domainId = roleBasedIdService.getDomainId(user);

        // 2. Access Token üret (2 dakika TTL)
        String accessToken = jwtUtil.generateAccessToken(user.getId(), user.getRole().name(), domainId);

        // 3. Refresh Token üret (UUID, 1 gün TTL) ve Redis'e kaydet
        String refreshToken = tokenService.createOrUpdateRefreshToken(user.getId(), domainId, accessToken);

        // 4. Access Token'ı Redis'e kaydet (manuel olarak oturum başlatma)
        tokenService.saveAccessToken(user.getId(), accessToken);

        // 5. Token'ları ve kullanıcı bilgilerini döndür
        return TokenResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .userId(user.getId())
                .role(user.getRole())
                .roleBasedId(domainId)
                .message("Login successful. Tokens generated.")
                .build();
    }
    public UserProfileResponse getUserProfile(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found with id: " + userId));

        return UserProfileResponse.builder()
                .id(user.getId())
                .name(user.getName())
                .surname(user.getSurname())
                .email(user.getEmail())
                .phone(user.getPhone())
                .role(user.getRole())
                .isMailVerified(user.isMailVerified())
                .build();
    }
}

