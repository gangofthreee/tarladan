package com.gangofthree.tarladan.modules.user.service;

import com.gangofthree.tarladan.modules.user.dto.UserRegisterRequest;
import com.gangofthree.tarladan.modules.depotOwner.entity.DepotOwner;
import com.gangofthree.tarladan.modules.farmer.entity.Farmer;
import com.gangofthree.tarladan.modules.user.entity.User;
import com.gangofthree.tarladan.common.enums.UserRole;
import com.gangofthree.tarladan.modules.user.repository.UserRepository;
import com.gangofthree.tarladan.modules.depotOwner.repository.DepotOwnerRepository;
import com.gangofthree.tarladan.modules.farmer.repository.FarmerRepository;
import com.gangofthree.tarladan.modules.verification.service.VerificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final VerificationService verificationService;
    private final FarmerRepository farmerRepository;
    private final DepotOwnerRepository depotOwnerRepository;

    @Override
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
        }

        verificationService.sendCode(savedUser);

        return savedUser;
    }
}

