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
    public TruckAd createAd(AddTruckAdRequest request, Long truckerId) {

        Trucker trucker = truckerRepository.findById(truckerId)
                .orElseThrow(() -> new EntityNotFoundException("Trucker bulunamadı: " + truckerId));

        Truck truck = truckRepository.findById(request.getTruckId())
                .orElseThrow(() -> new EntityNotFoundException("Kamyon bulunamadı: " + request.getTruckId()));

        if (!truck.getTrucker().getId().equals(truckerId)) {
            throw new IllegalStateException("Bu kamyon size ait olmadığı için ilan oluşturamazsınız.");
        }

        if (request.getStartDate().isAfter(request.getEndDate())) {
            throw new IllegalArgumentException("Başlangıç tarihi bitiş tarihinden sonra olamaz.");
        }

        TruckAd truckAd = TruckAd.builder()
                .trucker(trucker)
                .truck(truck)
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
                .truckId(ad.getTruck().getId())
                .capacityTon(ad.getTruck().getCapacityTon().toString())
                .imageUrl(ad.getTruck().getImageUrl())
                .startDate(ad.getStartDate())
                .endDate(ad.getEndDate())
                .pricePerKm(ad.getPricePerKm())
                .build();
    }

    @Override
    public TruckAdResponse updateTruckAd(Long adId, UpdateTruckAdRequest request, Long truckerId) {

        TruckAd ad = truckAdRepository.findById(adId)
                .orElseThrow(() -> new EntityNotFoundException("İlan bulunamadı: " + adId));

        if (!ad.getTrucker().getId().equals(truckerId)) {
            throw new SecurityException("Bu ilan size ait değil, güncelleyemezsiniz!");
        }

        if (request.getStartDate() != null) ad.setStartDate(request.getStartDate());
        if (request.getEndDate() != null) ad.setEndDate(request.getEndDate());
        if (request.getPricePerKm() != null) ad.setPricePerKm(request.getPricePerKm());

        TruckAd updated = truckAdRepository.save(ad);
        return convertToResponseDto(updated);
    }


    @Override
    public void deleteTruckAd(Long adId, Long truckerId) {

        TruckAd ad = truckAdRepository.findById(adId)
                .orElseThrow(() -> new EntityNotFoundException("Silinecek ilan bulunamadı: " + adId));

        if (!ad.getTrucker().getId().equals(truckerId)) {
            throw new SecurityException("Bu ilan size ait değil, silemezsiniz!");
        }

        truckAdRepository.delete(ad);
    }

    @Override
    public List<TruckAdResponse> getMyTruckAds(Long truckerId) {
        // Truckere ait bütün ilanları çek
        List<TruckAd> ads = truckAdRepository.findByTruckerId(truckerId);

        // Response DTO'ya dönüştür
        return ads.stream()
                .map(this::convertToResponseDto)
                .collect(Collectors.toList());
    }


}
