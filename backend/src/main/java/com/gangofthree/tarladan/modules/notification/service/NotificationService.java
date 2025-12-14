package com.gangofthree.tarladan.modules.notification.service;

import com.gangofthree.tarladan.modules.notification.entity.Notification;
import com.gangofthree.tarladan.modules.notification.repository.NotificationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

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
        // İleride buraya e-mail veya push notification servisi de eklenebilir.
    }

    public List<Notification> getMyNotifications(Long userId) {
        return notificationRepository.findByRecipientIdOrderByCreatedAtDesc(userId);
    }

    public void markAsRead(Long notificationId) {
        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new RuntimeException("Bildirim bulunamadı"));

        notification.setRead(true);
        notificationRepository.save(notification);
    }

    // Sadece okunmamış bildirim sayısını getir (Navbar'daki kırmızı ikon için)
    public long getUnreadCount(Long userId) {
        // Repository'e şu metodu eklemen gerekecek:
        // long countByRecipientIdAndIsReadFalse(Long recipientId);
        return notificationRepository.countByRecipientIdAndIsReadFalse(userId);
    }
}
