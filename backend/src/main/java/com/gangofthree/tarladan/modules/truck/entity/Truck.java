package com.gangofthree.tarladan.modules.truck.entity;

import com.gangofthree.tarladan.modules.trucker.entity.Trucker;
import jakarta.persistence.*;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.math.BigInteger;

@Entity
@Table(name = "truck")
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class Truck {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "trucker_id_FK", referencedColumnName = "id", nullable = false)
    private Trucker trucker;

    @NotBlank(message = "Arac bilgisi bos birakilamaz.")
    private String vehicle;

    @NotNull(message = "kapasite bos birakilamaz.")
    @Min(value = 1, message = "kapasite 0'dan buyuk olmalidir")
    private BigInteger capacityTon;

    @NotBlank(message = "plaka bilgisi bos birakilamaz.")
    private String plate;

    private String imageUrl;

}
