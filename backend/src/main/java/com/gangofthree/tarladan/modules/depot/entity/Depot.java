package com.gangofthree.tarladan.modules.depot.entity;

import com.gangofthree.tarladan.modules.depotOwner.entity.DepotOwner;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "depot")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Depot {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // ManyToOne çünkü birden fazla depo aynı DepotOwner'a ait olabilir
    @ManyToOne
    @JoinColumn(name = "depo_owner_id", referencedColumnName = "id", nullable = false)
    private DepotOwner depotOwner;

    @Column(nullable = false)
    private String address;

    @Column(nullable = false)
    private Double sizeM2;

    @Column(nullable = false)
    private Double capacityTon;

    @Column(nullable = false)
    private Double price;
}

