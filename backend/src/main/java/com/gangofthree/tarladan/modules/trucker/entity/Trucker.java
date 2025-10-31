package com.gangofthree.tarladan.modules.trucker.entity;

import com.gangofthree.tarladan.modules.user.entity.User;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "truckers")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Trucker {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne
    @JoinColumn(name="user_id", referencedColumnName = "id")
            private User user;
}
