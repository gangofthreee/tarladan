package com.gangofthree.tarladan.modules.order.service;

import com.gangofthree.tarladan.modules.order.dto.OrderCreateRequest;
import com.gangofthree.tarladan.modules.order.dto.OrderResponse;
import com.gangofthree.tarladan.shared.enums.OrderStatus;

import java.util.List;

public interface OrderService {
    OrderResponse createOrder(OrderCreateRequest req, Long customerId);
    List<OrderResponse> getAllOrders();
    OrderResponse getOrderByIdForCustomer(Long id, Long customerId);
    List<OrderResponse> getOrdersByCustomer(Long customerId);
    OrderResponse updateStatus(Long id, OrderStatus status);
    void deleteOrder(Long id);
}




