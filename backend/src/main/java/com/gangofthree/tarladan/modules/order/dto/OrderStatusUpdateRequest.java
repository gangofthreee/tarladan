package com.gangofthree.tarladan.modules.order.dto;

import com.gangofthree.tarladan.shared.enums.OrderStatus;
import lombok.Data;

@Data
public class OrderStatusUpdateRequest {
    private OrderStatus status;
}

