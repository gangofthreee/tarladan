package com.gangofthree.tarladan.modules.truckAd.repository;

import com.gangofthree.tarladan.modules.truckAd.entity.TruckAd;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;

public interface TruckAdRepository extends JpaRepository<TruckAd, Long> {

    // JOIN FETCH pulls trucker, trucker.user and truck in one query to avoid N+1 selects when listing ads
    @Query("SELECT ad FROM TruckAd ad JOIN FETCH ad.trucker t JOIN FETCH t.user JOIN FETCH ad.truck " +
            "WHERE ad.startDate <= :searchEndDate AND ad.endDate >= :searchStartDate")
    List<TruckAd> findActiveAdsByAvailability(
            @Param("searchStartDate") LocalDate searchStartDate,
            @Param("searchEndDate") LocalDate searchEndDate);

    @Query("SELECT ad FROM TruckAd ad JOIN FETCH ad.trucker t JOIN FETCH t.user JOIN FETCH ad.truck " +
            "WHERE t.id = :truckerId")
    List<TruckAd> findByTruckerId(@Param("truckerId") Long truckerId);

}