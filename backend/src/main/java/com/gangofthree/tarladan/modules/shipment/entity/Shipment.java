package com.gangofthree.tarladan.modules.shipment.entity;

import com.gangofthree.tarladan.modules.truck.entity.Truck;
import jakarta.persistence.*;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.math.BigInteger;

@Entity
@Table(name = "shipment")
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class Shipment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Truck tablosuyla ilişki (Foreign Key)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "truck_id", referencedColumnName = "id", nullable = false)
    private Truck truck;

    @NotBlank(message = "Gönderim çıkış lokasyonu boş bırakılamaz.")
    @Column(name = "loc_from", nullable = false)
    private String locFrom;

    @NotBlank(message = "Gönderim varış lokasyonu boş bırakılamaz.")
    @Column(name = "loc_to", nullable = false)
    private String locTo;

    @NotNull(message = "Kilometre başına fiyat boş bırakılamaz.")
    @Min(value = 1, message = "Kilometre başına fiyat 0'dan büyük olmalıdır.")
    @Column(name = "price_per_km", nullable = false)
    private BigInteger pricePerKm;
}

