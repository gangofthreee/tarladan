package com.gangofthree.tarladan.entity;

import jakarta.validation.constraints.NotBlank;
import java.time.LocalDateTime;
import org.hibernate.annotations.CreationTimestamp;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "products")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder

public class Products {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name="farmer_id", referencedColumnName = "id") 
	private Farmer farmer;

    //@OnetoOne
    //JoinColumn(name="depo_id", referencedColumnName = "id") 
	//private Depo depo;

    @NotBlank(message = "Name cannot be empty")
    private String name;
    
    @NotBlank(message = "Kg cannot be empty")
    private BigInteger quantity_kg;

    @NotBlank(message = "price cannot be empty")
    private BigInteger price_per_kg;

    @NotBlank(message = "minimum purchase amount cannot be empty")
    private BigInteger min_buy;

    @CreationTimestamp
    private LocalDateTime created_ad

    @Column(name = "image_path")
    private String image_path;

}