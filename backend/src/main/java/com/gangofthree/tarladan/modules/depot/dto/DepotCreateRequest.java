package com.gangofthree.tarladan.modules.depot.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class DepotCreateRequest {
    private String address; // nullable - reverse geocoding ile doldurulacak
    private Double latitude;
    private Double longitude;
    private Double sizeM2;
    private Double capacityTon;
    private Double price;
}
