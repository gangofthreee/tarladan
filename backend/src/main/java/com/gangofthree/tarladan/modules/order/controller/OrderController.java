package com.gangofthree.tarladan.modules.order.controller;

import com.gangofthree.tarladan.modules.order.dto.OrderCreateRequest;
import com.gangofthree.tarladan.modules.order.dto.OrderResponse;
import com.gangofthree.tarladan.modules.order.dto.OrderStatusUpdateRequest;
import com.gangofthree.tarladan.modules.order.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;

    // 🔥 Order oluştururken customerId sadece JWT’den alınır
    @PostMapping("/create")
    public ResponseEntity<OrderResponse> createOrder(
            @RequestAttribute("domainId") Long customerId,
            @RequestBody OrderCreateRequest request
    ) {
        return ResponseEntity.ok(orderService.createOrder(request, customerId));
    }

    // 🔥 Customer kendi siparişlerini görür
    @GetMapping("/my-orders")
    public ResponseEntity<List<OrderResponse>> getMyOrders(
            @RequestAttribute("domainId") Long customerId
    ) {
        return ResponseEntity.ok(orderService.getOrdersByCustomer(customerId));
    }

    // 🔥 Customer kendi sipariş detayını görür (güvenlik kontrolü service katmanında)
    @GetMapping("/{id}")
    public ResponseEntity<OrderResponse> getOrderById(
            @PathVariable Long id,
            @RequestAttribute("domainId") Long customerId
    ) {
        return ResponseEntity.ok(orderService.getOrderByIdForCustomer(id, customerId));
    }

    // ⚠ Admin veya Manager tarafından kullanılabilir
    @GetMapping
    public ResponseEntity<List<OrderResponse>> getAllOrders() {
        return ResponseEntity.ok(orderService.getAllOrders());
    }

    // ⚠ Sipariş durumu sadece admin/trucker tarafından güncellenebilir
    @PutMapping("/{id}/status")
    public ResponseEntity<OrderResponse> updateStatus(
            @PathVariable Long id,
            @RequestBody OrderStatusUpdateRequest request
    ) {
        return ResponseEntity.ok(orderService.updateStatus(id, request.getStatus()));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteOrder(@PathVariable Long id) {
        orderService.deleteOrder(id);
        return ResponseEntity.noContent().build();
    }
}
