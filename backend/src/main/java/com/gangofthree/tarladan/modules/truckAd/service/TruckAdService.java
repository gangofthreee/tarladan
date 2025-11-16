package com.gangofthree.tarladan.modules.truckAd.service;

import com.gangofthree.tarladan.modules.truckAd.Entity.TruckAd;
import com.gangofthree.tarladan.modules.truckAd.dto.AddTruckAdRequest;
import com.gangofthree.tarladan.modules.truckAd.dto.TruckAdResponse;
import com.gangofthree.tarladan.modules.truckAd.dto.GetTruckAdsRequest;
import com.gangofthree.tarladan.modules.truckAd.dto.UpdateTruckAdRequest;

import java.util.List;

public interface TruckAdService {

    TruckAd createAd(AddTruckAdRequest request, Long truckerId);

    List<TruckAdResponse> getAvailableTruckAds(GetTruckAdsRequest request);

    TruckAdResponse updateTruckAd(Long adId, UpdateTruckAdRequest request, Long truckerId);

    void deleteTruckAd(Long adId, Long truckerId);

    List<TruckAdResponse> getMyTruckAds(Long truckerId);

}

