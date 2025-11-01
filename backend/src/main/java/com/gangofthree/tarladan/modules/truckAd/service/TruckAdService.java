package com.gangofthree.tarladan.modules.truckAd.service;

import com.gangofthree.tarladan.modules.truckAd.Entity.TruckAd;
import com.gangofthree.tarladan.modules.truckAd.dto.AddTruckAdRequest;

public interface TruckAdService {
    TruckAd createAd(AddTruckAdRequest addTruckAdRequest);
}
