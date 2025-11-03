package com.gangofthree.tarladan.modules.truck.repository;

import com.gangofthree.tarladan.modules.truck.entity.Truck;
import com.gangofthree.tarladan.modules.trucker.entity.Trucker;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface TruckRepository extends JpaRepository<Truck, Long> {
    Optional<Truck> findByPlate(String plate);

    List<Truck> findAllByTrucker(Trucker trucker);

}
