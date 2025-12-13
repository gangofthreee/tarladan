package com.gangofthree.tarladan.modules.truck.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;
import java.io.Serializable;
import java.math.BigInteger;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class TruckResponse implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long id;
    // private String plate_number;
    private String vehicle;
    private BigInteger capacityTon;
    private String imageUrl;
    private Long truckerId;
    private BigInteger basePrice;


}