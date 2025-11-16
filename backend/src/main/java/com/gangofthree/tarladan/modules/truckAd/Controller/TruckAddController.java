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

    @PostMapping("/create")
    public ResponseEntity<TruckAd> createAd(
            @RequestAttribute("domainId") Long truckerId,
            @RequestBody AddTruckAdRequest request) {

        TruckAd newAd = truckAdService.createAd(request, truckerId);
        return ResponseEntity.ok(newAd);
    }

    @GetMapping
    public ResponseEntity<?> getAvailableTruckAds(@ModelAttribute GetTruckAdsRequest request) {
        List<TruckAdResponse> availableAds = truckAdService.getAvailableTruckAds(request);

        if (availableAds.isEmpty()) {
            return ResponseEntity.ok("Belirtilen tarihlerde uygun kamyon yok.");
        }
        return ResponseEntity.ok(availableAds);
    }

    @PatchMapping("/update/{adId}")
    public ResponseEntity<TruckAdResponse> updateTruckAd(
            @PathVariable Long adId,
            @RequestAttribute("domainId") Long truckerId,
            @RequestBody UpdateTruckAdRequest request) {

        TruckAdResponse updatedAd = truckAdService.updateTruckAd(adId, request, truckerId);
        return ResponseEntity.ok(updatedAd);
    }

    @DeleteMapping("/delete/{adId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteTruckAd(
            @PathVariable Long adId,
            @RequestAttribute("domainId") Long truckerId) {

        truckAdService.deleteTruckAd(adId, truckerId);
    }

    @GetMapping("/my-ads")
    public ResponseEntity<List<TruckAdResponse>> getMyAds(
            @RequestAttribute("domainId") Long truckerId
    ) {
        List<TruckAdResponse> myAds = truckAdService.getMyTruckAds(truckerId);
        return ResponseEntity.ok(myAds);
    }

}

