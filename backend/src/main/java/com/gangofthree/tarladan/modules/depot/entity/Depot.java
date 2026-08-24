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

    // ManyToOne because multiple depots can belong to the same DepotOwner.
    // Lazy-fetched: listing/detail responses only need the owner's id, and Hibernate can
    // resolve getId() from an uninitialized proxy without hitting the database, avoiding N+1 selects.
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "depo_owner_id", referencedColumnName = "id", nullable = false)
    private DepotOwner depotOwner;

    @Column(nullable = true)
    private String address;

    @Column(nullable = false)
    private Double latitude;

    @Column(nullable = false)
    private Double longitude;

    @Column(nullable = false)
    private Double sizeM2;

    @Column(nullable = false)
    private Double capacityTon;

    @Column(nullable = false)
    private Double price;
}

