package com.gangofthree.tarladan.modules.truckAd.repository;

import com.gangofthree.tarladan.modules.truckAd.Entity.TruckAd;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;

public interface TruckAdRepository extends JpaRepository<TruckAd, Long> {

    @Query("SELECT ad FROM TruckAd ad WHERE ad.startDate <= :searchEndDate AND ad.endDate >= :searchStartDate")
    List<TruckAd> findActiveAdsByAvailability(
            @Param("searchStartDate") LocalDate searchStartDate,
            @Param("searchEndDate") LocalDate searchEndDate);

    List<TruckAd> findByTruckerId(Long truckerId);

}