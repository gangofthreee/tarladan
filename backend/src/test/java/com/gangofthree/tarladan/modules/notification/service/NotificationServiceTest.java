package com.gangofthree.tarladan.modules.notification.service;

import com.gangofthree.tarladan.modules.notification.entity.Notification;
import com.gangofthree.tarladan.modules.notification.repository.NotificationRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class NotificationServiceTest {

    @Mock
    private NotificationRepository notificationRepository;

    @InjectMocks
    private NotificationService notificationService;

    @Test
    void whenSendNotification_thenSaveIsCalled() {
        notificationService.sendNotification(1L, "Title", "Message");
        verify(notificationRepository).save(any(Notification.class));
    }

    @Test
    void whenGetMyNotifications_thenReturnsList() {
        when(notificationRepository.findByRecipientIdOrderByCreatedAtDesc(1L))
                .thenReturn(List.of(new Notification(), new Notification()));

        List<Notification> notifications = notificationService.getMyNotifications(1L);
        assertThat(notifications).hasSize(2);
    }

    @Test
    void whenMarkAsRead_thenNotificationIsUpdated() {
        Notification notification = new Notification();
        notification.setRecipientId(1L);
        notification.setRead(false);

        when(notificationRepository.findById(1L)).thenReturn(Optional.of(notification));

        notificationService.markAsRead(1L, 1L);

        assertThat(notification.isRead()).isTrue();
        verify(notificationRepository).save(notification);
    }

    @Test
    void whenMarkAsRead_byNonOwner_thenThrowsAndDoesNotSave() {
        Notification notification = new Notification();
        notification.setRecipientId(1L);
        notification.setRead(false);

        when(notificationRepository.findById(1L)).thenReturn(Optional.of(notification));

        assertThatThrownBy(() -> notificationService.markAsRead(1L, 2L))
                .isInstanceOf(SecurityException.class);

        assertThat(notification.isRead()).isFalse();
        verify(notificationRepository, never()).save(any(Notification.class));
    }
}
