package com.gangofthree.tarladan.modules.order.dto;

import com.gangofthree.tarladan.shared.enums.OrderStatus;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class OrderStatusUpdateRequest {
    @NotNull(message = "Durum boş bırakılamaz.")
    private OrderStatus status;
}

