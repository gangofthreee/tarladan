package com.gangofthree.tarladan.modules.truckAd.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
@Builder
public class TruckAdResponse {

    private Long adId;

    // Trucker Bilgisi
    private String truckerName;

    // Truck Bilgisi
    private String vehicle;
    private String plate;

    // İlan Bilgileri
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd")
    private LocalDate startDate;

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd")
    private LocalDate endDate;

    private BigDecimal pricePerKm;
}