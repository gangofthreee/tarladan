package com.gangofthree.tarladan.modules.depot.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class DepotCreateRequest {
    private String address; // nullable - filled in via reverse geocoding
    private Double latitude;
    private Double longitude;
    private Double sizeM2;
    private Double capacityTon;
    private Double price;
}
