package com.gangofthree.tarladan.modules.order.dto;

import lombok.Data;

@Data
public class OrderCreateRequest {
    private Long customerId;
    private Long productId;
    private Long depotId;
    private Long truckId;
    private String locFrom;
    private String locTo;
    private Integer quantityKg;
}

