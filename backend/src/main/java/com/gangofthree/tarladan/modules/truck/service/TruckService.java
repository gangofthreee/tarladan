package com.gangofthree.tarladan.modules.truck.service;

import com.gangofthree.tarladan.modules.truck.entity.Truck;
import com.gangofthree.tarladan.modules.truck.dto.AddTruckRequest;

public interface TruckService {
    Truck addTruck(AddTruckRequest addTruckRequest);
}
