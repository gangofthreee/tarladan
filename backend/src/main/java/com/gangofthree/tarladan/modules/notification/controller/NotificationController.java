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

    // 1. Fetch all of my notifications (called when the page opens)
    @GetMapping("/my-notifications")
    public ResponseEntity<List<Notification>> getMyNotifications(
            @RequestAttribute("uid") Long userId
    ) {
        return ResponseEntity.ok(notificationService.getMyNotifications(userId));
    }

    // 2. Fetch the count for the navbar's unread badge (may be called on every page change)
    @GetMapping("/unread-count")
    public ResponseEntity<Long> getUnreadCount(
            @RequestAttribute("uid") Long userId
    ) {
        return ResponseEntity.ok(notificationService.getUnreadCount(userId));
    }

    // 3. Called when a notification is clicked, or "mark all as read" is used
    @PutMapping("/{id}/read")
    public ResponseEntity<Void> markAsRead(
            @PathVariable Long id,
            @RequestAttribute("uid") Long userId
    ) {
        notificationService.markAsRead(id, userId);
        return ResponseEntity.ok().build();
    }
}
