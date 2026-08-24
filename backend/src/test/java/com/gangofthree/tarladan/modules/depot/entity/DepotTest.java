package com.gangofthree.tarladan.modules.depot.entity;

import com.gangofthree.tarladan.modules.depotOwner.entity.DepotOwner;
import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import jakarta.validation.ValidatorFactory;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.Set;

import static org.assertj.core.api.Assertions.assertThat;

class DepotTest {

    private Validator validator;

    @BeforeEach
    void setUp() {
        ValidatorFactory factory = Validation.buildDefaultValidatorFactory();
        validator = factory.getValidator();
    }

    @Test
    void whenAllFieldsAreValid_thenNoViolations() {
        Depot depot = Depot.builder()
                .depotOwner(new DepotOwner())
                .address("123 Main St")
                .latitude(40.0)
                .longitude(29.0)
                .sizeM2(100.0)
                .capacityTon(50.0)
                .price(1000.0)
                .build();

        // Note: JPA @Column(nullable=false) is not checked by Bean Validation unless @NotNull is present.
        // Depot currently has no Bean Validation annotations, so this only exercises the builder/getters.
        Set<ConstraintViolation<Depot>> violations = validator.validate(depot);
        assertThat(violations).isEmpty();

        assertThat(depot.getAddress()).isEqualTo("123 Main St");
        assertThat(depot.getLatitude()).isEqualTo(40.0);
    }
}
