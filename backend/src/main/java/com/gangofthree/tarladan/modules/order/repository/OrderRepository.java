package com.gangofthree.tarladan.modules.order.repository;

import com.gangofthree.tarladan.modules.order.entity.Order;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {

    // Fetch-joins the associations used by OrderServiceImpl#mapToResponse so that
    // listing endpoints don't trigger an N+1 query per order.
    @Query("SELECT o FROM Order o " +
            "JOIN FETCH o.customer c " +
            "JOIN FETCH c.user " +
            "JOIN FETCH o.product " +
            "JOIN FETCH o.depot " +
            "LEFT JOIN FETCH o.shipment s " +
            "LEFT JOIN FETCH s.truck")
    List<Order> findAllWithDetails();

    @Query("SELECT o FROM Order o " +
            "JOIN FETCH o.customer c " +
            "JOIN FETCH c.user " +
            "JOIN FETCH o.product " +
            "JOIN FETCH o.depot " +
            "LEFT JOIN FETCH o.shipment s " +
            "LEFT JOIN FETCH s.truck " +
            "WHERE o.customer.id = :customerId")
    List<Order> findByCustomerIdWithDetails(@Param("customerId") Long customerId);
}

