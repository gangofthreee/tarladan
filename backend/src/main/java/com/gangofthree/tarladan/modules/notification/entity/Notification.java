package com.gangofthree.tarladan.modules.notification.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "notifications")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Bildirimin gideceği kişinin ID'si (Bu User tablosundaki ana ID olmalı)
    private Long recipientId;

    private String title;
    private String message;

    @Builder.Default
    private boolean isRead = false;

    private LocalDateTime createdAt;

    @PrePersist
    public void prePersist() {
        this.createdAt = LocalDateTime.now();
    }
}
