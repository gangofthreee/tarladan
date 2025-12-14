package com.gangofthree.tarladan.modules.notification.service;

import com.gangofthree.tarladan.modules.order.entity.Order;
import com.gangofthree.tarladan.modules.order.event.OrderCreatedEvent;
import lombok.RequiredArgsConstructor;
import org.springframework.context.event.EventListener;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionalEventListener;

@Component
@RequiredArgsConstructor
public class NotificationEventListener {

    private final NotificationService notificationService;

    // @Async kullanarak bildirimin ana sipariş işlemini yavaşlatmasını engelleriz (Opsiyonel ama önerilir)
    // TransactionalEventListener: Sipariş DB'ye commit edildikten sonra çalışır. Hata olursa bildirim gitmez.
    @TransactionalEventListener
    public void handleOrderCreatedEvent(OrderCreatedEvent event) {
        Order order = event.getOrder();

        String orderInfo = "Sipariş No: " + order.getId() + " - Ürün: " + order.getProduct().getName();

        // 1. Customer'a Bildirim
        // Not: Burada user.getId() kullanıyoruz. Çünkü Auth mekanizması genellikle User tablosuna bakar.
        Long customerUserId = order.getCustomer().getUser().getId();
        notificationService.sendNotification(
                customerUserId,
                "Siparişiniz Alındı",
                "Siparişiniz başarıyla oluşturuldu. " + orderInfo
        );

        // 2. Farmer'a Bildirim
        // (Entity yapında Product -> Farmer -> User ilişkisi olduğunu varsayıyorum)
        Long farmerUserId = order.getProduct().getFarmer().getUser().getId();
        notificationService.sendNotification(
                farmerUserId,
                "Yeni Sipariş Var!",
                "Ürününüz için yeni bir sipariş geldi. " + orderInfo
        );

        // 3. Depot Owner'a Bildirim
        // (Entity yapında Depot -> DepotOwner -> User ilişkisi olduğunu varsayıyorum)
        Long depotOwnerUserId = order.getDepot().getDepotOwner().getUser().getId();
        notificationService.sendNotification(
                depotOwnerUserId,
                "Depo Çıkış Talebi",
                "Deponuzdan ürün çıkışı yapılacak. " + orderInfo
        );

        // 4. Trucker'a Bildirim
        // (Entity yapında Truck -> Trucker (User) ilişkisi olduğunu varsayıyorum)
        Long truckerUserId = order.getShipment().getTruck().getTrucker().getId(); // Veya getOwner()
        notificationService.sendNotification(
                truckerUserId,
                "Yeni Taşıma İşi",
                "Yeni bir taşıma işi atandı. " + orderInfo
        );
    }
}
