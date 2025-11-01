package com.gangofthree.tarladan.modules.truckAd.dto;

import lombok.Data;
import org.springframework.format.annotation.DateTimeFormat;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;

@Data
public class GetTruckAdsRequest {

    @NotNull(message = "Başlangıç tarihi boş olamaz.")
    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
    private LocalDate searchStartDate;

    @NotNull(message = "Bitiş tarihi boş olamaz.")
    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
    private LocalDate searchEndDate;


}