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
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import com.gangofthree.tarladan.modules.truck.dto.TruckResponse; 


import java.util.List;


@RestController
@RequestMapping("/truck")
@RequiredArgsConstructor
public class TruckController {

    private final TruckService truckService;

    @CacheEvict(value = "trucks", allEntries = true)
    @PostMapping(value = "/create", consumes = {"multipart/form-data"})
    public ResponseEntity<Truck> createTruck(@ModelAttribute AddTruckRequest request,
                                             @RequestAttribute("domainId") Long truckerId) {
        // domainId JwtAuthFilter'da SecurityContext veya request attribute olarak set edilecek
        Truck createdTruck = truckService.addTruck(request, truckerId);
        return ResponseEntity.ok(createdTruck);
    }

    @CacheEvict(value = "trucks", allEntries = true)
    @PatchMapping(value = "/update/{id}", consumes = {"multipart/form-data"})
    public ResponseEntity<Truck> updateTruck(@PathVariable Long id,
                                             @ModelAttribute UpdateTruckRequest request,
                                             @RequestAttribute("domainId") Long truckerId) {
        Truck updatedTruck = truckService.updateTruck(id, request, truckerId);
        return ResponseEntity.ok(updatedTruck);
    }

    @CacheEvict(value = "trucks", allEntries = true)
    @DeleteMapping("/delete/{id}")
    public ResponseEntity<String> deleteTruck(@PathVariable Long id,
                                              @RequestAttribute("domainId") Long truckerId) {
        truckService.deleteTruck(id, truckerId);
        return ResponseEntity.ok("Truck başarıyla silindi.");
    }

    @Cacheable(value = "trucks", key = "'my_trucks_' + #truckerId")
    @GetMapping("/get")
    public List<TruckResponse> getMyTrucks(@RequestAttribute("domainId") Long truckerId) {
        List<TruckResponse> trucks = truckService.getTrucksByTruckerId(truckerId);
        return trucks;
    }

    @Cacheable(value = "trucks", key = "'all'")
    @GetMapping("/getAllTrucks")
    public List<TruckResponse> getAllTrucks() {
        return truckService.getAllTrucks();
    }

    @Cacheable(value = "trucks", key = "#id")
    @GetMapping("/{id}")
    public TruckResponse getTruckById(@PathVariable Long id,
                                              @RequestAttribute("domainId") Long truckerId) {
        TruckResponse truck = truckService.getTruckByIdAndTrucker(id, truckerId);
        return truck;
    }
}