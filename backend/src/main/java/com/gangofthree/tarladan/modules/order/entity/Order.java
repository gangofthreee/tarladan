package com.gangofthree.tarladan.modules.order.entity;

import com.gangofthree.tarladan.shared.enums.OrderStatus;
import com.gangofthree.tarladan.modules.customer.entity.Customer;
import com.gangofthree.tarladan.modules.depot.entity.Depot;
import com.gangofthree.tarladan.modules.product.entity.Product;
import com.gangofthree.tarladan.modules.shipment.entity.Shipment;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.math.BigInteger;
import java.time.LocalDateTime;

@Entity
@Table(name = "orders") // plural is used because "order" is a reserved SQL keyword
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class Order {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Customer relationship
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_id_FK", referencedColumnName = "id", nullable = false)
    private Customer customer;

    // Product relationship
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id_FK", referencedColumnName = "id", nullable = false)
    private Product product;

    // Depot relationship
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "depot_id_FK", referencedColumnName = "id", nullable = false)
    private Depot depot;

    // Shipment relationship
    @OneToOne(fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @JoinColumn(name = "shipment_id_FK", referencedColumnName = "id")
    private Shipment shipment;

    @NotNull
    private Integer quantity;

    @NotNull
    private BigInteger totalPrice;

    @Builder.Default
    private LocalDateTime orderDate = LocalDateTime.now();

    @NotNull
    @Enumerated(EnumType.STRING)
    @Builder.Default
    private OrderStatus status = OrderStatus.PENDING;
}

