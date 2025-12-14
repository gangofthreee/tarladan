package com.gangofthree.tarladan.modules.order.service;

import com.gangofthree.tarladan.modules.order.event.OrderCreatedEvent;
import com.gangofthree.tarladan.shared.enums.OrderStatus;
import com.gangofthree.tarladan.modules.customer.entity.Customer;
import com.gangofthree.tarladan.modules.customer.repository.CustomerRepository;
import com.gangofthree.tarladan.modules.depot.entity.Depot;
import com.gangofthree.tarladan.modules.depot.repository.DepotRepository;
import com.gangofthree.tarladan.modules.order.dto.OrderCreateRequest;
import com.gangofthree.tarladan.modules.order.dto.OrderResponse;
import com.gangofthree.tarladan.modules.order.entity.Order;
import com.gangofthree.tarladan.modules.order.repository.OrderRepository;
import com.gangofthree.tarladan.modules.product.entity.Product;
import com.gangofthree.tarladan.modules.product.repository.ProductRepository;
import com.gangofthree.tarladan.modules.shipment.entity.Shipment;
import com.gangofthree.tarladan.modules.shipment.repository.ShipmentRepository;
import com.gangofthree.tarladan.modules.truck.entity.Truck;
import com.gangofthree.tarladan.modules.truck.repository.TruckRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;

import java.math.BigInteger;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class OrderServiceImpl implements OrderService {

    private final OrderRepository orderRepository;
    private final CustomerRepository customerRepository;
    private final ProductRepository productRepository;
    private final DepotRepository depotRepository;
    private final TruckRepository truckRepository;
    private final ShipmentRepository shipmentRepository;
    private final ApplicationEventPublisher eventPublisher;

    @Override
    public OrderResponse createOrder(OrderCreateRequest req, Long customerId) {

        Customer customer = customerRepository.findById(customerId)
                .orElseThrow(() -> new EntityNotFoundException("Customer not found"));

        Product product = productRepository.findById(req.getProductId())
                .orElseThrow(() -> new EntityNotFoundException("Product not found"));

        Depot depot = depotRepository.findById(req.getDepotId())
                .orElseThrow(() -> new EntityNotFoundException("Depot not found"));

        Truck truck = truckRepository.findById(req.getTruckId())
                .orElseThrow(() -> new EntityNotFoundException("Truck not found"));

        BigInteger totalPrice = product.getPrice_per_kg()
                .multiply(BigInteger.valueOf(req.getQuantityKg()));

        Shipment shipment = Shipment.builder()
                .truck(truck)
                .locFrom(req.getLocFrom())
                .locTo(req.getLocTo())
                .pricePerKm(BigInteger.valueOf(15))
                .build();

        shipmentRepository.save(shipment);

        Order order = Order.builder()
                .customer(customer)
                .product(product)
                .depot(depot)
                .shipment(shipment)
                .quantity(req.getQuantityKg())
                .totalPrice(totalPrice)
                .status(OrderStatus.PENDING)
                .build();

        orderRepository.save(order);
        eventPublisher.publishEvent(new OrderCreatedEvent(this, order));
        return mapToResponse(order);
    }

    @Override
    public OrderResponse getOrderByIdForCustomer(Long id, Long customerId) {
        Order order = orderRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Order not found"));

        // 🔥 Sadece kendi siparişini görebilir
        if (!order.getCustomer().getId().equals(customerId)) {
            throw new SecurityException("Bu sipariş size ait değil!");
        }

        return mapToResponse(order);
    }

    @Override
    public List<OrderResponse> getOrdersByCustomer(Long customerId) {
        return orderRepository.findByCustomer_Id(customerId)
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<OrderResponse> getAllOrders() {
        return orderRepository.findAll()
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public OrderResponse updateStatus(Long id, OrderStatus status) {
        Order order = orderRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Order not found"));

        order.setStatus(status);
        orderRepository.save(order);

        return mapToResponse(order);
    }

    @Override
    public void deleteOrder(Long id) {
        orderRepository.deleteById(id);
    }

    private OrderResponse mapToResponse(Order order) {
        return OrderResponse.builder()
                .id(order.getId())
                .customerName(order.getCustomer().getUser().getName())
                .productName(order.getProduct().getName())
                .depotName(order.getDepot().getAddress())
                .truckPlate(order.getShipment().getTruck().getPlate())
                .locFrom(order.getShipment().getLocFrom())
                .locTo(order.getShipment().getLocTo())
                .quantityKg(order.getQuantity())
                .pricePerKg(order.getProduct().getPrice_per_kg())
                .totalPrice(order.getTotalPrice())
                .status(order.getStatus())
                .build();
    }
}

