package com.gangofthree.tarladan.modules.truck.repository;

import com.gangofthree.tarladan.modules.truck.entity.Truck;
import com.gangofthree.tarladan.modules.trucker.entity.Trucker;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface TruckRepository extends JpaRepository<Truck, Long> {
    Optional<Truck> findByPlate(String plate);

    List<Truck> findAllByTrucker(Trucker trucker);

    // Fetches trucker and trucker.user eagerly in a single query to avoid N+1 selects when listing all trucks
    @Query("SELECT t FROM Truck t JOIN FETCH t.trucker tr JOIN FETCH tr.user")
    List<Truck> findAllWithTruckerAndUser();

}
