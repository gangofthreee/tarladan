package com.gangofthree.tarladan.modules.shipment.entity;

import com.gangofthree.tarladan.modules.truck.entity.Truck;
import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import jakarta.validation.ValidatorFactory;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.math.BigInteger;
import java.util.Set;

import static org.assertj.core.api.Assertions.assertThat;

class ShipmentTest {

    private Validator validator;

    @BeforeEach
    void setUp() {
        ValidatorFactory factory = Validation.buildDefaultValidatorFactory();
        validator = factory.getValidator();
    }

    @Test
    void whenAllFieldsAreValid_thenNoViolations() {
        Shipment shipment = Shipment.builder()
                .truck(new Truck())
                .locFrom("Istanbul")
                .locTo("Ankara")
                .pricePerKm(BigInteger.valueOf(10))
                .build();

        Set<ConstraintViolation<Shipment>> violations = validator.validate(shipment);
        assertThat(violations).isEmpty();
    }

    @Test
    void whenLocFromIsBlank_thenViolation() {
        Shipment shipment = Shipment.builder()
                .truck(new Truck())
                .locFrom("")
                .locTo("Ankara")
                .pricePerKm(BigInteger.valueOf(10))
                .build();

        Set<ConstraintViolation<Shipment>> violations = validator.validate(shipment);
        assertThat(violations).isNotEmpty();
        assertThat(violations.iterator().next().getMessage()).isEqualTo("Gönderim çıkış lokasyonu boş bırakılamaz.");
    }

    @Test
    void whenPricePerKmIsZero_thenViolation() {
        Shipment shipment = Shipment.builder()
                .truck(new Truck())
                .locFrom("Istanbul")
                .locTo("Ankara")
                .pricePerKm(BigInteger.ZERO)
                .build();

        Set<ConstraintViolation<Shipment>> violations = validator.validate(shipment);
        assertThat(violations).isNotEmpty();
        assertThat(violations.iterator().next().getMessage()).isEqualTo("Kilometre başına fiyat 0'dan büyük olmalıdır.");
    }
}
