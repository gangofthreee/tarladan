package com.gangofthree.tarladan.modules.shipment.repository;

import com.gangofthree.tarladan.modules.shipment.entity.Shipment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ShipmentRepository extends JpaRepository<Shipment, Long> {

    List<Shipment> findByTruck_Id(Long truckId);
}

