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
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
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
        // Check email & phone uniqueness
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new IllegalArgumentException("Email already in use");
        }
        if (userRepository.existsByPhone(request.getPhone())) {
            throw new IllegalArgumentException("Phone already in use");
        }

        String roleString = String.valueOf(request.getRole()); // becomes the string "null" if role is missing
        UserRole userRole;
        try {
            userRole = UserRole.valueOf(roleString.toUpperCase()); // case-insensitive enum match
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("Invalid role provided: " + roleString);
        }


        // Hash the password
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

        // Persist the corresponding role-specific entity
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

        try {
            verificationService.sendCode(savedUser);
        } catch (Exception e) {
            log.error("Failed to send verification email to user: {}. Error: {}", savedUser.getEmail(), e.getMessage());
            // We do not re-throw the exception here to ensure the user is persisted.
            // The user will remain unverified, but we can verify them manually or fix SMTP and resend.
        }

        return savedUser;
    }

    @Override
    @Transactional
    public TokenResponse login(UserLoginRequest request) {
        // Look up the user by email
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new IllegalArgumentException("User not found with email: " + request.getEmail()));

        // Verify the password
        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new IllegalArgumentException("Invalid password");
        }

        // Require a verified email
        if (!user.isMailVerified()) {
            throw new IllegalArgumentException("Email is not verified");
        }

        // 1. Resolve the role-specific domain id (farmerId, truckerId, etc.)
        Long domainId = roleBasedIdService.getDomainId(user);

        // 2. Generate the access token (short TTL)
        String accessToken = jwtUtil.generateAccessToken(user.getId(), user.getRole().name(), domainId);

        // 3. Generate the refresh token (UUID, longer TTL) and store it in Redis
        String refreshToken = tokenService.createOrUpdateRefreshToken(user.getId(), domainId, accessToken);

        // 4. Store the access token in Redis (tracks the active session)
        tokenService.saveAccessToken(user.getId(), accessToken);

        // 5. Return the tokens and user information
        return TokenResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .userId(user.getId())
                .role(user.getRole())
                .roleBasedId(domainId)
                .message("Login successful. Tokens generated.")
                .build();
    }

    @Override
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

