package com.gangofthree.tarladan.modules.notification.entity;

import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;

class NotificationTest {

    @Test
    void testNotificationBuilderAndPrePersist() {
        Notification notification = Notification.builder()
                .recipientId(1L)
                .title("Test Title")
                .message("Test Message")
                .build();

        // Simulate PrePersist manually since we are not in a JPA environment
        notification.prePersist();

        assertThat(notification.getRecipientId()).isEqualTo(1L);
        assertThat(notification.getTitle()).isEqualTo("Test Title");
        assertThat(notification.getMessage()).isEqualTo("Test Message");
        assertThat(notification.isRead()).isFalse(); // Default value
        assertThat(notification.getCreatedAt()).isNotNull();
        assertThat(notification.getCreatedAt()).isBeforeOrEqualTo(LocalDateTime.now());
    }
}
