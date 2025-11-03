package com.gangofthree.tarladan.modules.truck.Controller;

import com.gangofthree.tarladan.modules.truck.dto.AddTruckRequest;
import com.gangofthree.tarladan.modules.truck.dto.UpdateTruckRequest;
import com.gangofthree.tarladan.modules.truck.entity.Truck;
import com.gangofthree.tarladan.modules.truck.service.TruckService;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;


@RestController
@RequestMapping("/truck")
@RequiredArgsConstructor
public class TruckController {

    private final TruckService truckService;

    @PostMapping(value = "/create", consumes = {"multipart/form-data"})
    public ResponseEntity<Truck> createTruck(@ModelAttribute AddTruckRequest request) {
        Truck createdTruck = truckService.addTruck(request);
        return ResponseEntity.ok(createdTruck);
    }

    @PatchMapping(value = "/update/{id}", consumes = {"multipart/form-data"})
    public ResponseEntity<Truck> updateTruck(@PathVariable Long id, @ModelAttribute UpdateTruckRequest request) {
        Truck updatedTruck = truckService.updateTruck(id, request);
        return ResponseEntity.ok(updatedTruck);
    }

    @DeleteMapping("/delete/{id}")
    public ResponseEntity<String> deleteTruck(@PathVariable Long id) {
        truckService.deleteTruck(id);
        return ResponseEntity.ok("Truck başarıyla silindi.");
    }

    @GetMapping("/get/{id}")
    public ResponseEntity<List<Truck>> getTrucksByTruckerId(@PathVariable("id") Long truckerId) {
        try {
            List<Truck> trucks = truckService.getTrucksByTruckerId(truckerId);
            return ResponseEntity.ok(trucks);
        } catch (EntityNotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
    }

    // 2. Sistemdeki tüm Truck'ları döndüren endpoint
    @GetMapping("/getAllTrucks")
    public ResponseEntity<List<Truck>> getAllTrucks() {
        List<Truck> trucks = truckService.getAllTrucks();
        return ResponseEntity.ok(trucks);
    }

}
