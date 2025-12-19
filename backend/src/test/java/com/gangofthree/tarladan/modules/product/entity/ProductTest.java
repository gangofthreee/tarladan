package com.gangofthree.tarladan.modules.product.entity;

import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import jakarta.validation.ValidatorFactory;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.math.BigInteger;
import java.util.Set;

import static org.assertj.core.api.Assertions.assertThat;

class ProductTest {

    private Validator validator;

    @BeforeEach
    void setUp() {
        ValidatorFactory factory = Validation.buildDefaultValidatorFactory();
        validator = factory.getValidator();
    }

    @Test
    void whenAllFieldsAreValid_thenNoViolations() {
        Product product = Product.builder()
                .name("Tomato")
                .quantity_kg(BigInteger.valueOf(100))
                .price_per_kg(BigInteger.valueOf(10))
                .min_buy(BigInteger.valueOf(5))
                .build();

        Set<ConstraintViolation<Product>> violations = validator.validate(product);
        assertThat(violations).isEmpty();
    }

    @Test
    void whenQuantityIsZero_thenViolation() {
        Product product = Product.builder()
                .name("Tomato")
                .quantity_kg(BigInteger.ZERO)
                .price_per_kg(BigInteger.valueOf(10))
                .min_buy(BigInteger.valueOf(5))
                .build();

        Set<ConstraintViolation<Product>> violations = validator.validate(product);
        assertThat(violations).isNotEmpty();
        assertThat(violations.iterator().next().getMessage()).isEqualTo("Miktar 0'dan büyük olmalıdır.");
    }

    @Test
    void whenPriceIsZero_thenViolation() {
        Product product = Product.builder()
                .name("Tomato")
                .quantity_kg(BigInteger.valueOf(100))
                .price_per_kg(BigInteger.ZERO)
                .min_buy(BigInteger.valueOf(5))
                .build();

        Set<ConstraintViolation<Product>> violations = validator.validate(product);
        assertThat(violations).isNotEmpty();
        assertThat(violations.iterator().next().getMessage()).isEqualTo("Fiyat 0'dan büyük olmalıdır.");
    }
}
