package com.gangofthree.tarladan.modules.truck.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.web.multipart.MultipartFile;

import java.math.BigInteger;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class AddTruckRequest {
    private Long truckerId;
    private String vehicle;
    private BigInteger capacityTon;
    private String plate;
    private MultipartFile photo;
    private BigInteger basePrice;
}

