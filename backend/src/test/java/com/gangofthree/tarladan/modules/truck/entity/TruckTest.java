package com.gangofthree.tarladan.modules.truck.entity;

import com.gangofthree.tarladan.modules.trucker.entity.Trucker;
import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import jakarta.validation.ValidatorFactory;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.math.BigInteger;
import java.util.Set;

import static org.assertj.core.api.Assertions.assertThat;

class TruckTest {

    private Validator validator;

    @BeforeEach
    void setUp() {
        ValidatorFactory factory = Validation.buildDefaultValidatorFactory();
        validator = factory.getValidator();
    }

    @Test
    void whenAllFieldsAreValid_thenNoViolations() {
        Truck truck = Truck.builder()
                .trucker(new Trucker())
                .vehicle("Mercedes Actros")
                .capacityTon(BigInteger.valueOf(20))
                .plate("34 ABC 123")
                .build();

        Set<ConstraintViolation<Truck>> violations = validator.validate(truck);
        assertThat(violations).isEmpty();
    }

    @Test
    void whenCapacityIsZero_thenViolation() {
        Truck truck = Truck.builder()
                .trucker(new Trucker())
                .vehicle("Mercedes Actros")
                .capacityTon(BigInteger.ZERO)
                .plate("34 ABC 123")
                .build();

        Set<ConstraintViolation<Truck>> violations = validator.validate(truck);
        assertThat(violations).isNotEmpty();
        assertThat(violations.iterator().next().getMessage()).isEqualTo("kapasite 0'dan buyuk olmalidir");
    }

    @Test
    void whenPlateIsBlank_thenViolation() {
        Truck truck = Truck.builder()
                .trucker(new Trucker())
                .vehicle("Mercedes Actros")
                .capacityTon(BigInteger.valueOf(20))
                .plate("")
                .build();

        Set<ConstraintViolation<Truck>> violations = validator.validate(truck);
        assertThat(violations).isNotEmpty();
        assertThat(violations.iterator().next().getMessage()).isEqualTo("plaka bilgisi bos birakilamaz.");
    }
}
