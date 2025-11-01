package com.gangofthree.tarladan.modules.truck.Controller;

import com.gangofthree.tarladan.modules.truck.dto.AddTruckRequest;
import com.gangofthree.tarladan.modules.truck.dto.UpdateTruckRequest;
import com.gangofthree.tarladan.modules.truck.entity.Truck;
import com.gangofthree.tarladan.modules.truck.service.TruckService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;


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

}
