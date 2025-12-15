package com.gangofthree.tarladan.modules.depot.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor; 
import java.io.Serializable;  

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class DepotResponse implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long id;
    private String address;
    private Double latitude;
    private Double longitude;
    private Double sizeM2;
    private Double capacityTon;
    private Double price;
    private Long depotOwnerId;
}
