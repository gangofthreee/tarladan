package com.gangofthree.tarladan.modules.user.service;

import com.gangofthree.tarladan.modules.customer.repository.CustomerRepository;
import com.gangofthree.tarladan.modules.depotOwner.repository.DepotOwnerRepository;
import com.gangofthree.tarladan.modules.farmer.repository.FarmerRepository;
import com.gangofthree.tarladan.modules.trucker.repository.TruckerRepository;
import com.gangofthree.tarladan.modules.user.dto.UserRegisterRequest;
import com.gangofthree.tarladan.modules.user.entity.User;
import com.gangofthree.tarladan.modules.user.repository.UserRepository;
import com.gangofthree.tarladan.modules.verification.service.VerificationService;
import com.gangofthree.tarladan.security.jwt.JwtUtil;
import com.gangofthree.tarladan.security.service.TokenService;
import com.gangofthree.tarladan.shared.enums.UserRole;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class UserServiceImplTest {

    @Mock
    private UserRepository userRepository;
    @Mock
    private PasswordEncoder passwordEncoder;
    @Mock
    private VerificationService verificationService;
    @Mock
    private JwtUtil jwtUtil;
    @Mock
    private TokenService tokenService;
    @Mock
    private RoleBasedIdService roleBasedIdService;
    @Mock
    private FarmerRepository farmerRepository;
    @Mock
    private DepotOwnerRepository depotOwnerRepository;
    @Mock
    private CustomerRepository customerRepository;
    @Mock
    private TruckerRepository truckerRepository;

    @InjectMocks
    private UserServiceImpl userService;

    @Test
    void whenRegisteringNewUser_thenUserIsSavedAndVerificationSent() {
        // Arrange
        UserRegisterRequest request = new UserRegisterRequest();
        request.setName("John");
        request.setSurname("Doe");
        request.setEmail("john@example.com");
        request.setPhone("1234567890");
        request.setPassword("password");
        request.setRole(UserRole.FARMER);

        when(userRepository.existsByEmail(request.getEmail())).thenReturn(false);
        when(userRepository.existsByPhone(request.getPhone())).thenReturn(false);
        when(passwordEncoder.encode(request.getPassword())).thenReturn("encodedPassword");
        
        User savedUser = User.builder()
                .id(1L)
                .name(request.getName())
                .email(request.getEmail())
                .role(request.getRole())
                .build();
        
        when(userRepository.save(any(User.class))).thenReturn(savedUser);

        // Act
        User result = userService.register(request);

        // Assert
        assertThat(result).isNotNull();
        assertThat(result.getEmail()).isEqualTo(request.getEmail());
        
        verify(userRepository).save(any(User.class));
        verify(farmerRepository).save(any()); // Since role is FARMER
        verify(verificationService).sendCode(savedUser);
    }

    @Test
    void whenRegisteringExistingEmail_thenThrowException() {
        // Arrange
        UserRegisterRequest request = new UserRegisterRequest();
        request.setEmail("john@example.com");
        
        when(userRepository.existsByEmail(request.getEmail())).thenReturn(true);

        // Act & Assert
        assertThrows(IllegalArgumentException.class, () -> userService.register(request));
        
        verify(userRepository, never()).save(any(User.class));
    }
}
