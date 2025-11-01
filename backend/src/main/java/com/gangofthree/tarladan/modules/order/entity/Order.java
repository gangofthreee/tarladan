package com.gangofthree.tarladan.modules.order.entity;

import com.gangofthree.tarladan.common.enums.OrderStatus;
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
@Table(name = "orders") // order SQL'de keyword olduğu için çoğul kullanmak güvenli
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class Order {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Customer ilişkisi
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_id_FK", referencedColumnName = "id", nullable = false)
    private Customer customer;

    // Product ilişkisi
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id_FK", referencedColumnName = "id", nullable = false)
    private Product product;

    // Depot ilişkisi
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "depot_id_FK", referencedColumnName = "id", nullable = false)
    private Depot depot;

    // Shipment ilişkisi
    @OneToOne(fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @JoinColumn(name = "shipment_id_FK", referencedColumnName = "id")
    private Shipment shipment;

    @NotNull
    private Integer quantity;

    @NotNull
    private BigInteger totalPrice;

    private LocalDateTime orderDate = LocalDateTime.now();

    @Enumerated(EnumType.STRING)
    private OrderStatus status = OrderStatus.PENDING;
}

