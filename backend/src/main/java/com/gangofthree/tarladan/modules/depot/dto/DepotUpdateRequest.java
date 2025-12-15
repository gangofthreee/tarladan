package com.gangofthree.tarladan.modules.depot.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DepotUpdateRequest {
    private String address;
    private Double latitude;
    private Double longitude;
    private Double sizeM2;
    private Double capacityTon;
    private Double price;
}
