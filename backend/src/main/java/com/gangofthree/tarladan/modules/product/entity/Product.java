package com.gangofthree.tarladan.modules.product.entity;

import com.gangofthree.tarladan.modules.depot.entity.Depot;
import com.gangofthree.tarladan.modules.farmer.entity.Farmer;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;

import jakarta.validation.constraints.NotNull;
import jakarta.persistence.*;
import lombok.*;

import java.math.*;

@Entity
@Table(name = "products")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder

public class Product {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "farmer_id", referencedColumnName = "id")
    private Farmer farmer;

    @ManyToOne
    @JoinColumn(name = "depot_id", referencedColumnName = "id")
    private Depot depot;

    @NotBlank(message = "Name cannot be empty")
    private String name;

    @NotNull(message = "Kg cannot be empty")
    @Min(value = 1, message = "Miktar 0'dan büyük olmalıdır.")
    private BigInteger quantity_kg;

    @NotNull(message = "price cannot be empty")
    @Min(value = 1, message = "Fiyat 0'dan büyük olmalıdır.")
    private BigInteger price_per_kg;

    @NotNull(message = "minimum purchase amount cannot be empty")
    @Min(value = 1, message = "Minimum alım miktarı 0'dan büyük olmalıdır.")
    private BigInteger min_buy;

    @Column(name = "image_path")
    private String image_path;

}