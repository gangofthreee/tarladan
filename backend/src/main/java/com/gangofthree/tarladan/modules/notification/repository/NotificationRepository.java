package com.gangofthree.tarladan.modules.notification.repository;

import com.gangofthree.tarladan.modules.notification.entity.Notification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, Long> {
    // Fetch all notifications for a user, newest first
    List<Notification> findByRecipientIdOrderByCreatedAtDesc(Long recipientId);
    // Count notifications where recipientId matches AND isRead is false
    long countByRecipientIdAndIsReadFalse(Long recipientId);
}
