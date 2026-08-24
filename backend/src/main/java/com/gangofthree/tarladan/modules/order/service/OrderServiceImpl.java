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
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigInteger;
import java.util.EnumSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class OrderServiceImpl implements OrderService {

    // Placeholder flat rate until distance-based shipment pricing is implemented.
    private static final BigInteger DEFAULT_PRICE_PER_KM = BigInteger.valueOf(15);

    // Once an order reaches one of these statuses it is considered final and
    // can no longer transition to another status.
    private static final Set<OrderStatus> TERMINAL_STATUSES = EnumSet.of(OrderStatus.DELIVERED, OrderStatus.CANCELLED);

    private final OrderRepository orderRepository;
    private final CustomerRepository customerRepository;
    private final ProductRepository productRepository;
    private final DepotRepository depotRepository;
    private final TruckRepository truckRepository;
    private final ShipmentRepository shipmentRepository;
    private final ApplicationEventPublisher eventPublisher;

    @Override
    @Transactional
    public OrderResponse createOrder(OrderCreateRequest req, Long customerId) {

        Customer customer = customerRepository.findById(customerId)
                .orElseThrow(() -> new EntityNotFoundException("Customer not found"));

        Product product = productRepository.findById(req.getProductId())
                .orElseThrow(() -> new EntityNotFoundException("Product not found"));

        Depot depot = depotRepository.findById(req.getDepotId())
                .orElseThrow(() -> new EntityNotFoundException("Depot not found"));

        Truck truck = truckRepository.findById(req.getTruckId())
                .orElseThrow(() -> new EntityNotFoundException("Truck not found"));

        // The product belongs to exactly one depot; make sure the requested depot
        // actually matches it instead of trusting the client-supplied depotId blindly.
        if (product.getDepot() == null || !product.getDepot().getId().equals(depot.getId())) {
            throw new IllegalArgumentException("The selected product does not belong to the specified depot");
        }

        BigInteger requestedQuantity = BigInteger.valueOf(req.getQuantityKg());

        if (requestedQuantity.compareTo(product.getMin_buy()) < 0) {
            throw new IllegalArgumentException("Requested quantity is below the minimum purchase amount for this product");
        }

        if (requestedQuantity.compareTo(product.getQuantity_kg()) > 0) {
            throw new IllegalArgumentException("Insufficient stock for the requested quantity");
        }

        BigInteger totalPrice = product.getPrice_per_kg().multiply(requestedQuantity);

        // Reserve the stock atomically as part of this transaction.
        product.setQuantity_kg(product.getQuantity_kg().subtract(requestedQuantity));
        productRepository.save(product);

        Shipment shipment = Shipment.builder()
                .truck(truck)
                .locFrom(req.getLocFrom())
                .locTo(req.getLocTo())
                .pricePerKm(DEFAULT_PRICE_PER_KM)
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
        log.info("Order {} created for customer {} (product {}, quantity {}kg)", order.getId(), customerId, product.getId(), req.getQuantityKg());
        return mapToResponse(order);
    }

    @Override
    @Transactional(readOnly = true)
    public OrderResponse getOrderByIdForCustomer(Long id, Long customerId) {
        Order order = orderRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Order not found"));

        // Customer may only view their own order
        if (!order.getCustomer().getId().equals(customerId)) {
            throw new SecurityException("Bu sipariş size ait değil!");
        }

        return mapToResponse(order);
    }

    @Override
    @Transactional(readOnly = true)
    public List<OrderResponse> getOrdersByCustomer(Long customerId) {
        return orderRepository.findByCustomerIdWithDetails(customerId)
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<OrderResponse> getAllOrders() {
        return orderRepository.findAllWithDetails()
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public OrderResponse updateStatus(Long id, OrderStatus status) {
        Order order = orderRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Order not found"));

        if (TERMINAL_STATUSES.contains(order.getStatus())) {
            throw new IllegalArgumentException("Order " + id + " is already " + order.getStatus() + " and its status can no longer be changed");
        }

        order.setStatus(status);
        orderRepository.save(order);
        log.info("Order {} status changed to {}", id, status);

        return mapToResponse(order);
    }

    @Override
    @Transactional
    public void deleteOrder(Long id) {
        orderRepository.deleteById(id);
    }

    private OrderResponse mapToResponse(Order order) {
        return OrderResponse.builder()
                .id(order.getId())
                .customerName(order.getCustomer().getUser().getName())
                .productName(order.getProduct().getName())
                .product_image_path(order.getProduct().getImage_path())
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

