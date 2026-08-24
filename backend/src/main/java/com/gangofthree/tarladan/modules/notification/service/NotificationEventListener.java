package com.gangofthree.tarladan.modules.notification.service;

import com.gangofthree.tarladan.modules.order.entity.Order;
import com.gangofthree.tarladan.modules.order.event.OrderCreatedEvent;
import com.gangofthree.tarladan.modules.truck.entity.Truck;
import com.gangofthree.tarladan.modules.trucker.entity.Trucker;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
@Slf4j
public class NotificationEventListener {

    private final NotificationService notificationService;

    // Runs synchronously, inside the same transaction as order creation, so that the lazily
    // loaded associations below (product.farmer, depot.depotOwner, shipment.truck.trucker) are
    // still reachable. Each notification is sent through sendNotificationSafely() below so that
    // a failure sending one notification cannot roll back order creation nor block the others.
    @EventListener
    public void handleOrderCreatedEvent(OrderCreatedEvent event) {
        Order order = event.getOrder();
        String orderInfo = "Sipariş No: " + order.getId() + " - Ürün: " + order.getProduct().getName();

        // ---------------------------------------------------------------------
        // 1. CUSTOMER NOTIFICATION
        // ---------------------------------------------------------------------
        if (order.getCustomer() != null && order.getCustomer().getUser() != null) {
            // Go through the User nested inside the Customer entity
            Long realUserId = order.getCustomer().getUser().getId();

            sendNotificationSafely(
                    realUserId,
                    "📦 Siparişiniz Alındı",
                    "Siparişiniz başarıyla oluşturuldu. " + orderInfo
            );
        }

        // ---------------------------------------------------------------------
        // 2. FARMER NOTIFICATION
        // ---------------------------------------------------------------------
        if (order.getProduct() != null &&
                order.getProduct().getFarmer() != null &&
                order.getProduct().getFarmer().getUser() != null) {

            // Use the ID of the User nested inside the Farmer entity, not the Farmer's own ID
            Long realUserId = order.getProduct().getFarmer().getUser().getId();

            sendNotificationSafely(
                    realUserId,
                    "🧑‍🌾 Yeni Sipariş Var!",
                    "Ürününüz satıldı! " + orderInfo
            );
        }

        // ---------------------------------------------------------------------
        // 3. DEPOT OWNER NOTIFICATION
        // ---------------------------------------------------------------------
        if (order.getDepot() != null &&
                order.getDepot().getDepotOwner() != null &&
                order.getDepot().getDepotOwner().getUser() != null) {

            // Use the ID of the User nested inside the DepotOwner entity
            Long realUserId = order.getDepot().getDepotOwner().getUser().getId();

            sendNotificationSafely(
                    realUserId,
                    "🏭 Depo Çıkış Talebi",
                    "Deponuzdan çıkış yapılacak. " + orderInfo
            );
        }

        // ---------------------------------------------------------------------
        // 4. TRUCKER NOTIFICATION
        // ---------------------------------------------------------------------
        if (order.getShipment() != null && order.getShipment().getTruck() != null) {
            Truck truck = order.getShipment().getTruck();
            Trucker trucker = truck.getTrucker();

            if (trucker != null && trucker.getUser() != null) {
                Long realUserId = trucker.getUser().getId();

                sendNotificationSafely(
                        realUserId,
                        "🚚 Yeni Taşıma İşi",
                        "Yeni iş atandı. Yola çıkmaya hazırlanın. " + orderInfo
                );
            }
        }
    }

    // A failure sending one recipient's notification (e.g. a transient DB issue) should not
    // prevent the remaining recipients in this event from being notified.
    private void sendNotificationSafely(Long recipientId, String title, String message) {
        try {
            notificationService.sendNotification(recipientId, title, message);
        } catch (Exception e) {
            log.error("Failed to send notification to user {}: {}", recipientId, e.getMessage(), e);
        }
    }
}