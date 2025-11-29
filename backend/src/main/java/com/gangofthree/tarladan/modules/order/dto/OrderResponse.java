package com.gangofthree.tarladan.modules.order.dto;

import com.gangofthree.tarladan.shared.enums.OrderStatus;
import lombok.Builder;
import lombok.Data;

import java.math.BigInteger;

@Data
@Builder
public class OrderResponse {
    private Long id;
    private String customerName;
    private String productName;
    private String depotName;
    private String truckPlate;
    private String locFrom;
    private String locTo;
    private Integer quantityKg;
    private BigInteger pricePerKg;
    private BigInteger totalPrice;
    private OrderStatus status;
}

