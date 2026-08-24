package com.gangofthree.tarladan.modules.notification.service;

import com.gangofthree.tarladan.modules.notification.entity.Notification;
import com.gangofthree.tarladan.modules.notification.repository.NotificationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private final NotificationRepository notificationRepository;

    public void sendNotification(Long recipientId, String title, String message) {
        Notification notification = Notification.builder()
                .recipientId(recipientId)
                .title(title)
                .message(message)
                .isRead(false)
                .build();

        notificationRepository.save(notification);
        // An email or push notification service could be plugged in here in the future.
    }

    public List<Notification> getMyNotifications(Long userId) {
        return notificationRepository.findByRecipientIdOrderByCreatedAtDesc(userId);
    }

    @Transactional
    public void markAsRead(Long notificationId, Long userId) {
        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new RuntimeException("Notification not found"));

        // A user may only mark their own notifications as read
        if (!notification.getRecipientId().equals(userId)) {
            throw new SecurityException("Bu bildirim size ait değil!");
        }

        notification.setRead(true);
        notificationRepository.save(notification);
    }

    // Fetch only the unread notification count (for the navbar's red badge)
    public long getUnreadCount(Long userId) {
        return notificationRepository.countByRecipientIdAndIsReadFalse(userId);
    }
}
