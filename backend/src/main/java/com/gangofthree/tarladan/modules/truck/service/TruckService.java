package com.gangofthree.tarladan.modules.truck.service;

import com.gangofthree.tarladan.modules.truck.entity.Truck;
import com.gangofthree.tarladan.modules.truck.dto.AddTruckRequest;
import com.gangofthree.tarladan.modules.truck.dto.UpdateTruckRequest;

import java.util.List;

public interface TruckService {
    Truck addTruck(AddTruckRequest addTruckRequest);

    Truck updateTruck(Long id, UpdateTruckRequest updateTruckRequest);

    void deleteTruck(Long id);

    List<Truck> getTrucksByTruckerId(Long truckerId);

    List<Truck> getAllTrucks();
}
