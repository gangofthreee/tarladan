package com.gangofthree.tarladan.modules.product.dto;

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
public class ProductResponse implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long id;
    private String name;
    private BigInteger quantity_kg;
    private BigInteger price_per_kg;
    private BigInteger min_buy;
    private String image_path;
    private Long depot_id;
    private Long farmer_id;
    private Double depot_latitude;
    private Double depot_longitude;

    //status field eklenebilir

}