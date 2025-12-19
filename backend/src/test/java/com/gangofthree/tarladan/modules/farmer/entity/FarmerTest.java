package com.gangofthree.tarladan.modules.farmer.entity;

import com.gangofthree.tarladan.modules.user.entity.User;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class FarmerTest {

    @Test
    void testFarmerBuilder() {
        User user = User.builder().id(1L).name("Farmer John").build();
        
        Farmer farmer = Farmer.builder()
                .id(1L)
                .user(user)
                .build();

        assertThat(farmer.getId()).isEqualTo(1L);
        assertThat(farmer.getUser()).isEqualTo(user);
        assertThat(farmer.getUser().getName()).isEqualTo("Farmer John");
    }
}
