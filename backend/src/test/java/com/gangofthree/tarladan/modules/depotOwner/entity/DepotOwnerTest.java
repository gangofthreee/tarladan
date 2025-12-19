package com.gangofthree.tarladan.modules.depotOwner.entity;

import com.gangofthree.tarladan.modules.user.entity.User;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class DepotOwnerTest {

    @Test
    void testDepotOwnerBuilder() {
        User user = User.builder().id(1L).name("Owner").build();
        
        DepotOwner depotOwner = DepotOwner.builder()
                .id(1L)
                .user(user)
                .build();

        assertThat(depotOwner.getId()).isEqualTo(1L);
        assertThat(depotOwner.getUser()).isEqualTo(user);
        assertThat(depotOwner.getUser().getName()).isEqualTo("Owner");
    }
}
