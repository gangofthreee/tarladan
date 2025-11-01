package com.gangofthree.tarladan.modules.truckAd.service;

import com.gangofthree.tarladan.modules.truck.entity.Truck;
import com.gangofthree.tarladan.modules.truck.repository.TruckRepository;
import com.gangofthree.tarladan.modules.truckAd.Entity.TruckAd;
import com.gangofthree.tarladan.modules.truckAd.dto.AddTruckAdRequest;
import com.gangofthree.tarladan.modules.truckAd.repository.TruckAdRepository;
import com.gangofthree.tarladan.modules.trucker.entity.Trucker;
import com.gangofthree.tarladan.modules.trucker.repository.TruckerRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class TruckAdServiceImpl implements TruckAdService {

    private final TruckAdRepository truckAdRepository;
    private final TruckerRepository truckerRepository;
    private final TruckRepository truckRepository;

    @Override
    public TruckAd createAd(AddTruckAdRequest request){
        Trucker trucker = truckerRepository.findById(request.getTruckerId())
                .orElseThrow(() -> new EntityNotFoundException(
                        "ID'si " + request.getTruckerId() + " olan Tırcı (Trucker) bulunamadı."));

        Truck truck = truckRepository.findById(request.getTruckId())
                .orElseThrow(() -> new EntityNotFoundException(
                        "ID'si " + request.getTruckId() + " olan Kamyon (Truck) bulunamadı."));

        if (!truck.getTrucker().getId().equals(trucker.getId())) {
            throw new IllegalStateException("Seçilen kamyon, ilanı açan tırcıya ait değil.");
        }

        if (request.getStartDate().isAfter(request.getEndDate())) {
            throw new IllegalArgumentException("Başlangıç tarihi, bitiş tarihinden sonra olamaz.");
        }

        TruckAd truckAd = TruckAd.builder()
                .trucker(trucker) // Bulunan Tırcı Entity'sini set ediyoruz
                .truck(truck)     // Bulunan Kamyon Entity'sini set ediyoruz
                .startDate(request.getStartDate())
                .endDate(request.getEndDate())
                .pricePerKm(request.getPricePerKm())
                .build();

        return truckAdRepository.save(truckAd);

    }
}
