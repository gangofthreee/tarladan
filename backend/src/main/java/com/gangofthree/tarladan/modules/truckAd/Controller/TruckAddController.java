package com.gangofthree.tarladan.modules.truckAd.Controller;

import com.gangofthree.tarladan.modules.truckAd.Entity.TruckAd;
import com.gangofthree.tarladan.modules.truckAd.dto.AddTruckAdRequest;
import com.gangofthree.tarladan.modules.truckAd.dto.GetTruckAdsRequest;
import com.gangofthree.tarladan.modules.truckAd.dto.TruckAdResponse;
import com.gangofthree.tarladan.modules.truckAd.dto.UpdateTruckAdRequest;
import com.gangofthree.tarladan.modules.truckAd.service.TruckAdService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("truck/ads")
@RequiredArgsConstructor
public class TruckAddController {

    private final TruckAdService truckAdService;

    @PostMapping(value = "/create")
    public ResponseEntity<TruckAd> createAd(@RequestBody AddTruckAdRequest request) {
        TruckAd newAd = truckAdService.createAd(request);
        return ResponseEntity.ok(newAd);
    }

    @GetMapping
    public ResponseEntity<?> getAvailableTruckAds(
            @ModelAttribute GetTruckAdsRequest request) {

        List<TruckAdResponse> availableAds = truckAdService.getAvailableTruckAds(request);

        if (availableAds.isEmpty()) {
            String message = "Belirtilen tarihlerde uygun kamyon yok.";
            return ResponseEntity.ok(message);
        }

        return ResponseEntity.ok(availableAds);
    }

    @PatchMapping("/update/{adId}")
    public ResponseEntity<TruckAdResponse> updateTruckAd(
            @PathVariable Long adId,
            @RequestBody UpdateTruckAdRequest request) {

        TruckAdResponse updatedAd = truckAdService.updateTruckAd(adId, request);
        return ResponseEntity.ok(updatedAd);
    }

    @DeleteMapping("/delete/{adId}")
    @ResponseStatus(HttpStatus.NO_CONTENT) // Başarılı silme sonrası 204 No Content döndürür
    public void deleteTruckAd(@PathVariable Long adId) {
        truckAdService.deleteTruckAd(adId);
    }

}
