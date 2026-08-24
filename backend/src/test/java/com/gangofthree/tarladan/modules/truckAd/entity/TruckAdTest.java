package com.gangofthree.tarladan.modules.truckAd.entity;

import com.gangofthree.tarladan.modules.truck.entity.Truck;
import com.gangofthree.tarladan.modules.trucker.entity.Trucker;
import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import jakarta.validation.ValidatorFactory;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Set;

import static org.assertj.core.api.Assertions.assertThat;

class TruckAdTest {

    private Validator validator;

    @BeforeEach
    void setUp() {
        ValidatorFactory factory = Validation.buildDefaultValidatorFactory();
        validator = factory.getValidator();
    }

    @Test
    void whenAllFieldsAreValid_thenNoViolations() {
        TruckAd truckAd = TruckAd.builder()
                .trucker(new Trucker())
                .truck(new Truck())
                .startDate(LocalDate.now())
                .endDate(LocalDate.now().plusDays(5))
                .pricePerKm(BigDecimal.valueOf(15.5))
                .build();

        Set<ConstraintViolation<TruckAd>> violations = validator.validate(truckAd);
        assertThat(violations).isEmpty();
    }

    @Test
    void whenPricePerKmIsNegative_thenViolation() {
        TruckAd truckAd = TruckAd.builder()
                .trucker(new Trucker())
                .truck(new Truck())
                .startDate(LocalDate.now())
                .endDate(LocalDate.now().plusDays(5))
                .pricePerKm(BigDecimal.valueOf(-1))
                .build();

        Set<ConstraintViolation<TruckAd>> violations = validator.validate(truckAd);
        assertThat(violations).isNotEmpty();
    }
}
