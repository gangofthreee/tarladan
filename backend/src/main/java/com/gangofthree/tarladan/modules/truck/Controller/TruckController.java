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

    // Artık client sadece access token gönderiyor; truckerId JWT’den alınacak
    @PostMapping(value = "/create", consumes = {"multipart/form-data"})
    public ResponseEntity<Truck> createTruck(@ModelAttribute AddTruckRequest request,
                                             @RequestAttribute("domainId") Long truckerId) {
        // domainId JwtAuthFilter'da SecurityContext veya request attribute olarak set edilecek
        Truck createdTruck = truckService.addTruck(request, truckerId);
        return ResponseEntity.ok(createdTruck);
    }

    @PatchMapping(value = "/update/{id}", consumes = {"multipart/form-data"})
    public ResponseEntity<Truck> updateTruck(@PathVariable Long id,
                                             @ModelAttribute UpdateTruckRequest request,
                                             @RequestAttribute("domainId") Long truckerId) {
        Truck updatedTruck = truckService.updateTruck(id, request, truckerId);
        return ResponseEntity.ok(updatedTruck);
    }

    @DeleteMapping("/delete/{id}")
    public ResponseEntity<String> deleteTruck(@PathVariable Long id,
                                              @RequestAttribute("domainId") Long truckerId) {
        truckService.deleteTruck(id, truckerId);
        return ResponseEntity.ok("Truck başarıyla silindi.");
    }

    @GetMapping("/get")
    public ResponseEntity<List<Truck>> getMyTrucks(@RequestAttribute("domainId") Long truckerId) {
        List<Truck> trucks = truckService.getTrucksByTruckerId(truckerId);
        return ResponseEntity.ok(trucks);
    }

    @GetMapping("/getAllTrucks")
    public ResponseEntity<List<Truck>> getAllTrucks() {
        return ResponseEntity.ok(truckService.getAllTrucks());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Truck> getTruckById(@PathVariable Long id,
                                              @RequestAttribute("domainId") Long truckerId) {
        Truck truck = truckService.getTruckByIdAndTrucker(id, truckerId);
        return ResponseEntity.ok(truck);
    }
}

