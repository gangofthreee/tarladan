package com.gangofthree.tarladan.modules.truckAd.service;

import com.gangofthree.tarladan.modules.truck.entity.Truck;
import com.gangofthree.tarladan.modules.truck.repository.TruckRepository;
import com.gangofthree.tarladan.modules.truckAd.Entity.TruckAd;
import com.gangofthree.tarladan.modules.truckAd.dto.AddTruckAdRequest;
import com.gangofthree.tarladan.modules.truckAd.dto.TruckAdResponse;
import com.gangofthree.tarladan.modules.truckAd.dto.GetTruckAdsRequest;
import com.gangofthree.tarladan.modules.truckAd.dto.UpdateTruckAdRequest;
import com.gangofthree.tarladan.modules.truckAd.repository.TruckAdRepository;
import com.gangofthree.tarladan.modules.trucker.entity.Trucker;
import com.gangofthree.tarladan.modules.trucker.repository.TruckerRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

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

    @Override
    public List<TruckAdResponse> getAvailableTruckAds(GetTruckAdsRequest request) {
        if (request.getSearchStartDate().isAfter(request.getSearchEndDate())) {
            throw new IllegalArgumentException("Arama başlangıç tarihi, bitiş tarihinden sonra olamaz.");
        }

        List<TruckAd> availableAds = truckAdRepository.findActiveAdsByAvailability(
                request.getSearchStartDate(),
                request.getSearchEndDate()
        );

        // liste bos
        if (availableAds.isEmpty()) {
            return List.of();
        }

        // Entity Listesi -> Response DTO Listesine Dönüşüm
        return availableAds.stream()
                .map(this::convertToResponseDto)
                .collect(Collectors.toList());
    }

    private TruckAdResponse convertToResponseDto(TruckAd ad) {
        String truckerName = ad.getTrucker().getUser().getName() + " " + ad.getTrucker().getUser().getSurname();

        return TruckAdResponse.builder()
                .adId(ad.getId())
                .truckerName(truckerName)
                .vehicle(ad.getTruck().getVehicle())
                .plate(ad.getTruck().getPlate())
                .startDate(ad.getStartDate())
                .endDate(ad.getEndDate())
                .pricePerKm(ad.getPricePerKm())
                .build();
    }

    @Override
    public TruckAdResponse updateTruckAd(Long adId, UpdateTruckAdRequest request) {

        TruckAd existingAd = truckAdRepository.findById(adId)
                .orElseThrow(() -> new EntityNotFoundException(
                        "ID'si " + adId + " olan Kamyon İlanı bulunamadı."));

        if (request.getStartDate() != null) {
            existingAd.setStartDate(request.getStartDate());
        }

        if (request.getEndDate() != null) {
            existingAd.setEndDate(request.getEndDate());
        }

        if (request.getPricePerKm() != null) {
            existingAd.setPricePerKm(request.getPricePerKm());
        }

        TruckAd updatedAd = truckAdRepository.save(existingAd);

        //Sonucu Response DTO'ya dönüştür
        return convertToResponseDto(updatedAd);
    }

    @Override
    public void deleteTruckAd(Long adId) {
        if (!truckAdRepository.existsById(adId)) {
            throw new EntityNotFoundException(
                    "ID'si " + adId + " olan silinecek Kamyon İlanı bulunamadı.");
        }
        truckAdRepository.deleteById(adId);
    }
}
