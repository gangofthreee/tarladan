package com.gangofthree.tarladan.modules.order.entity;

import com.gangofthree.tarladan.modules.customer.entity.Customer;
import com.gangofthree.tarladan.modules.depot.entity.Depot;
import com.gangofthree.tarladan.modules.product.entity.Product;
import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import jakarta.validation.ValidatorFactory;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.Set;

import static org.assertj.core.api.Assertions.assertThat;

class OrderTest {

    private Validator validator;

    @BeforeEach
    void setUp() {
        ValidatorFactory factory = Validation.buildDefaultValidatorFactory();
        validator = factory.getValidator();
    }

    @Test
    void whenAllFieldsAreValid_thenNoViolations() {
        Order order = Order.builder()
                .customer(new Customer())
                .product(new Product())
                .depot(new Depot())
                .quantity(10)
                .totalPrice(java.math.BigInteger.valueOf(100))
                .build();

        Set<ConstraintViolation<Order>> violations = validator.validate(order);
        assertThat(violations).isEmpty();
    }

    @Test
    void whenQuantityIsNull_thenViolation() {
        Order order = Order.builder()
                .customer(new Customer())
                .product(new Product())
                .depot(new Depot())
                .quantity(null)
                .totalPrice(java.math.BigInteger.valueOf(100))
                .build();

        Set<ConstraintViolation<Order>> violations = validator.validate(order);
        assertThat(violations).isNotEmpty();
    }
}
