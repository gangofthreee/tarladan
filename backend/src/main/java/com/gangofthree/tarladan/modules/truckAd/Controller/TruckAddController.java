package com.gangofthree.tarladan.modules.truckAd.Controller;

import com.gangofthree.tarladan.modules.truckAd.Entity.TruckAd;
import com.gangofthree.tarladan.modules.truckAd.dto.AddTruckAdRequest;
import com.gangofthree.tarladan.modules.truckAd.service.TruckAdService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

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
}
