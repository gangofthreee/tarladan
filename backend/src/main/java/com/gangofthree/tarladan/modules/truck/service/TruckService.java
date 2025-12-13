package com.gangofthree.tarladan.modules.truck.service;

import com.gangofthree.tarladan.modules.truck.entity.Truck;
import com.gangofthree.tarladan.modules.truck.dto.AddTruckRequest;
import com.gangofthree.tarladan.modules.truck.dto.UpdateTruckRequest;
import com.gangofthree.tarladan.modules.truck.dto.TruckResponse; 


import java.util.List;

public interface TruckService {

    Truck addTruck(AddTruckRequest addTruckRequest, Long truckerIdFromToken);

    Truck updateTruck(Long id, UpdateTruckRequest updateTruckRequest, Long truckerIdFromToken);

    void deleteTruck(Long id, Long truckerIdFromToken);

    List<TruckResponse> getTrucksByTruckerId(Long truckerIdFromToken);

    TruckResponse getTruckByIdAndTrucker(Long id, Long truckerIdFromToken);

    List<TruckResponse> getAllTrucks();
}


