package com.gangofthree.tarladan.modules.order.controller;

import com.gangofthree.tarladan.modules.order.dto.OrderCreateRequest;
import com.gangofthree.tarladan.modules.order.dto.OrderResponse;
import com.gangofthree.tarladan.modules.order.dto.OrderStatusUpdateRequest;
import com.gangofthree.tarladan.modules.order.service.OrderService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;

    // customerId is only ever taken from the JWT when creating an order
    @PostMapping("/create")
    public ResponseEntity<OrderResponse> createOrder(
            @RequestAttribute("domainId") Long customerId,
            @Valid @RequestBody OrderCreateRequest request
    ) {
        return ResponseEntity.ok(orderService.createOrder(request, customerId));
    }

    // Customer sees their own orders
    @GetMapping("/my-orders")
    public ResponseEntity<List<OrderResponse>> getMyOrders(
            @RequestAttribute("domainId") Long customerId
    ) {
        return ResponseEntity.ok(orderService.getOrdersByCustomer(customerId));
    }

    // Customer sees the detail of their own order (ownership check happens in the service layer)
    @GetMapping("/{id}")
    public ResponseEntity<OrderResponse> getOrderById(
            @PathVariable Long id,
            @RequestAttribute("domainId") Long customerId
    ) {
        return ResponseEntity.ok(orderService.getOrderByIdForCustomer(id, customerId));
    }

    // Intended for admin/manager use
    @GetMapping
    public ResponseEntity<List<OrderResponse>> getAllOrders() {
        return ResponseEntity.ok(orderService.getAllOrders());
    }

    // Intended for admin/trucker use to update order status
    @PutMapping("/{id}/status")
    public ResponseEntity<OrderResponse> updateStatus(
            @PathVariable Long id,
            @Valid @RequestBody OrderStatusUpdateRequest request
    ) {
        return ResponseEntity.ok(orderService.updateStatus(id, request.getStatus()));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteOrder(@PathVariable Long id) {
        orderService.deleteOrder(id);
        return ResponseEntity.noContent().build();
    }
}
