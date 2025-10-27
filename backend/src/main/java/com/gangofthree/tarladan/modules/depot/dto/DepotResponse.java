package com.gangofthree.tarladan.modules.depot.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
@Builder
public class DepotResponse {
    private Long id;
    private String address;
    private Double sizeM2;
    private Double capacityTon;
    private Double price;
    private Long depotOwnerId;
}

