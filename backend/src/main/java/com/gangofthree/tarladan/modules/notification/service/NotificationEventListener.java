package com.gangofthree.tarladan.modules.notification.service;

import com.gangofthree.tarladan.modules.order.entity.Order;
import com.gangofthree.tarladan.modules.order.event.OrderCreatedEvent;
import com.gangofthree.tarladan.modules.truck.entity.Truck;
import com.gangofthree.tarladan.modules.trucker.entity.Trucker; // Trucker entity importunu kontrol et
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
@Slf4j
public class NotificationEventListener {

    private final NotificationService notificationService;

    @EventListener
    public void handleOrderCreatedEvent(OrderCreatedEvent event) {
        Order order = event.getOrder();
        String orderInfo = "Sipariş No: " + order.getId() + " - Ürün: " + order.getProduct().getName();

        // ---------------------------------------------------------------------
        // 1. CUSTOMER BİLDİRİMİ
        // ---------------------------------------------------------------------
        if (order.getCustomer() != null && order.getCustomer().getUser() != null) {
            // Customer entity'sinin içindeki User'a gidiyoruz
            Long realUserId = order.getCustomer().getUser().getId();

            notificationService.sendNotification(
                    realUserId,
                    "📦 Siparişiniz Alındı",
                    "Siparişiniz başarıyla oluşturuldu. " + orderInfo
            );
        }

        // ---------------------------------------------------------------------
        // 2. FARMER BİLDİRİMİ
        // ---------------------------------------------------------------------
        if (order.getProduct() != null &&
                order.getProduct().getFarmer() != null &&
                order.getProduct().getFarmer().getUser() != null) {

            // Farmer entity'sinin ID'sini DEĞİL, içindeki User'ın ID'sini alıyoruz
            Long realUserId = order.getProduct().getFarmer().getUser().getId();

            notificationService.sendNotification(
                    realUserId,
                    "🧑‍🌾 Yeni Sipariş Var!",
                    "Ürününüz satıldı! " + orderInfo
            );
        }

        // ---------------------------------------------------------------------
        // 3. DEPOT OWNER BİLDİRİMİ
        // ---------------------------------------------------------------------
        if (order.getDepot() != null &&
                order.getDepot().getDepotOwner() != null &&
                order.getDepot().getDepotOwner().getUser() != null) {

            // DepotOwner tablosundaki ID=1'i değil, User tablosundaki ID=3'ü alıyoruz
            Long realUserId = order.getDepot().getDepotOwner().getUser().getId();

            notificationService.sendNotification(
                    realUserId,
                    "🏭 Depo Çıkış Talebi",
                    "Deponuzdan çıkış yapılacak. " + orderInfo
            );
        }

        // ---------------------------------------------------------------------
        // 4. TRUCKER BİLDİRİMİ (Hatayı Çözen Kısım)
        // ---------------------------------------------------------------------
        if (order.getShipment() != null && order.getShipment().getTruck() != null) {
            Truck truck = order.getShipment().getTruck();
            Trucker trucker = truck.getTrucker(); // Truck entity'nde getTrucker() olduğunu varsayıyorum

            if (trucker != null && trucker.getUser() != null) {


                Long realUserId = trucker.getUser().getId();

                notificationService.sendNotification(
                        realUserId,
                        "🚚 Yeni Taşıma İşi",
                        "Yeni iş atandı. Yola çıkmaya hazırlanın. " + orderInfo
                );
            }
        }
    }
}