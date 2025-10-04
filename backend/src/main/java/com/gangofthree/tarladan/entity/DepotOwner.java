package com.gangofthree.tarladan.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "depot_owner")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DepotOwner {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne
    @JoinColumn(name = "user_id", referencedColumnName = "id", nullable = false, unique = true)
    private User user;
}

