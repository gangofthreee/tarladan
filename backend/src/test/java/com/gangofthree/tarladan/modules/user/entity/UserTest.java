package com.gangofthree.tarladan.modules.user.entity;

import com.gangofthree.tarladan.shared.enums.UserRole;
import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import jakarta.validation.ValidatorFactory;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.Set;

import static org.assertj.core.api.Assertions.assertThat;

class UserTest {

    private Validator validator;

    @BeforeEach
    void setUp() {
        ValidatorFactory factory = Validation.buildDefaultValidatorFactory();
        validator = factory.getValidator();
    }

    @Test
    void whenAllFieldsAreValid_thenNoViolations() {
        User user = User.builder()
                .name("John")
                .surname("Doe")
                .phone("1234567890")
                .email("john.doe@example.com")
                .password("password123")
                .role(UserRole.FARMER)
                .build();

        Set<ConstraintViolation<User>> violations = validator.validate(user);
        assertThat(violations).isEmpty();
    }

    @Test
    void whenEmailIsInvalid_thenViolation() {
        User user = User.builder()
                .name("John")
                .surname("Doe")
                .phone("1234567890")
                .email("invalid-email")
                .password("password123")
                .role(UserRole.FARMER)
                .build();

        Set<ConstraintViolation<User>> violations = validator.validate(user);
        assertThat(violations).hasSize(1);
        assertThat(violations.iterator().next().getMessage()).isEqualTo("Invalid email format");
    }

    @Test
    void whenPasswordIsTooShort_thenViolation() {
        User user = User.builder()
                .name("John")
                .surname("Doe")
                .phone("1234567890")
                .email("john.doe@example.com")
                .password("123")
                .role(UserRole.FARMER)
                .build();

        Set<ConstraintViolation<User>> violations = validator.validate(user);
        assertThat(violations).hasSize(1);
        assertThat(violations.iterator().next().getMessage()).isEqualTo("Password must be at least 6 characters");
    }

    @Test
    void whenNameIsEmpty_thenViolation() {
        User user = User.builder()
                .name("")
                .surname("Doe")
                .phone("1234567890")
                .email("john.doe@example.com")
                .password("password123")
                .role(UserRole.FARMER)
                .build();

        Set<ConstraintViolation<User>> violations = validator.validate(user);
        assertThat(violations).isNotEmpty();
    }
}
