package com.gangofthree.tarladan.modules.truckAd.Entity;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.gangofthree.tarladan.modules.truck.entity.Truck;
import com.gangofthree.tarladan.modules.trucker.entity.Trucker;
import jakarta.persistence.*;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;

@Entity
@Table(name = "truckAd")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TruckAd {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "trucker_id_FK", nullable = false)
    private Trucker trucker;

    @ManyToOne
    @JoinColumn(name = "trucks_id_FK", nullable = false)
    private Truck truck;

    @Column(name = "start_date")
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd")
    private LocalDate startDate;

    @Column(name = "end_date")
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd")
    private LocalDate endDate;

    @Column(name = "price_per_km")
    @NotNull
    @Min(value = 0)
    private BigDecimal pricePerKm;
}
