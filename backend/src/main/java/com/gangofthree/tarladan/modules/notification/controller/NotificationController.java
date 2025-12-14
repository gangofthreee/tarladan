package com.gangofthree.tarladan.modules.notification.controller;

import com.gangofthree.tarladan.modules.notification.entity.Notification;
import com.gangofthree.tarladan.modules.notification.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    // 1. Tüm bildirimlerimi getir (Sayfa açılınca çağrılır)
    @GetMapping("/my-notifications")
    public ResponseEntity<List<Notification>> getMyNotifications(
            @RequestAttribute("domainId") Long userId
    ) {
        return ResponseEntity.ok(notificationService.getMyNotifications(userId));
    }

    // 2. Navbar'daki kırmızı baloncuk için sayı getir (Her sayfa geçişinde çağrılabilir)
    @GetMapping("/unread-count")
    public ResponseEntity<Long> getUnreadCount(
            @RequestAttribute("domainId") Long userId
    ) {
        return ResponseEntity.ok(notificationService.getUnreadCount(userId));
    }

    // 3. Bildirime tıklandığında veya "Tümünü Okundu İşaretle" dendiğinde çağrılır
    @PutMapping("/{id}/read")
    public ResponseEntity<Void> markAsRead(@PathVariable Long id) {
        notificationService.markAsRead(id);
        return ResponseEntity.ok().build();
    }
}
