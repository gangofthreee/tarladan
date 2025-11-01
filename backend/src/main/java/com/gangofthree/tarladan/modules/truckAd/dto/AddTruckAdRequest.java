package com.gangofthree.tarladan.modules.truckAd.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.*;
import org.springframework.format.annotation.DateTimeFormat;

import java.math.BigDecimal;
import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class AddTruckAdRequest {
    @NotNull(message = "Tırcı ID boş olamaz.")
    private Long truckerId;

    @NotNull(message = "Kamyon ID boş olamaz.")
    private Long truckId;

    @NotNull(message = "Başlangıç tarihi boş olamaz.")
    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
    private LocalDate startDate;

    @NotNull(message = "Bitiş tarihi boş olamaz.")
    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
    private LocalDate endDate;

    @NotNull(message = "Birim fiyat boş olamaz.")
    @Min(value = 0, message = "Birim fiyat 0'dan büyük olmalıdır.")
    private BigDecimal pricePerKm;
}