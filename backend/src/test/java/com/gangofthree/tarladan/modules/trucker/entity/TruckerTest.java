package com.gangofthree.tarladan.modules.trucker.entity;

import com.gangofthree.tarladan.modules.user.entity.User;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class TruckerTest {

    @Test
    void testTruckerBuilder() {
        User user = User.builder().id(1L).name("Trucker Tom").build();
        
        Trucker trucker = Trucker.builder()
                .id(1L)
                .user(user)
                .build();

        assertThat(trucker.getId()).isEqualTo(1L);
        assertThat(trucker.getUser()).isEqualTo(user);
        assertThat(trucker.getUser().getName()).isEqualTo("Trucker Tom");
    }
}
