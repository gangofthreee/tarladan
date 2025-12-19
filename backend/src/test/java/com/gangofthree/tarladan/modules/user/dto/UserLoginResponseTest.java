package com.gangofthree.tarladan.modules.user.dto;

import com.gangofthree.tarladan.shared.enums.UserRole;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class UserLoginResponseTest {

    @Test
    void testBuilderAndGetters() {
        UserLoginResponse response = UserLoginResponse.builder()
                .id(1L)
                .name("John")
                .surname("Doe")
                .email("john@example.com")
                .phone("1234567890")
                .role(UserRole.FARMER)
                .build();

        assertThat(response.getId()).isEqualTo(1L);
        assertThat(response.getName()).isEqualTo("John");
        assertThat(response.getSurname()).isEqualTo("Doe");
        assertThat(response.getEmail()).isEqualTo("john@example.com");
        assertThat(response.getPhone()).isEqualTo("1234567890");
        assertThat(response.getRole()).isEqualTo(UserRole.FARMER);
    }
}
