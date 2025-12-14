package com.gangofthree.tarladan.modules.notification.repository;

import com.gangofthree.tarladan.modules.notification.entity.Notification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, Long> {
    // Kullanıcıya ait okunmamış bildirimleri getir (örnek)
    List<Notification> findByRecipientIdOrderByCreatedAtDesc(Long recipientId);
    // "RecipientId'si bu olan VE isRead alanı FALSE olanları say"
    long countByRecipientIdAndIsReadFalse(Long recipientId);
}
