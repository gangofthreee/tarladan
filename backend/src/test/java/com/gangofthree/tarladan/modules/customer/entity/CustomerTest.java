package com.gangofthree.tarladan.modules.customer.entity;

import com.gangofthree.tarladan.modules.user.entity.User;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class CustomerTest {

    @Test
    void testCustomerBuilder() {
        User user = User.builder().id(1L).name("Customer Jane").build();
        
        Customer customer = Customer.builder()
                .id(1L)
                .user(user)
                .build();

        assertThat(customer.getId()).isEqualTo(1L);
        assertThat(customer.getUser()).isEqualTo(user);
        assertThat(customer.getUser().getName()).isEqualTo("Customer Jane");
    }
}
