package com.gangofthree.tarladan.modules.depot.controller;

import com.gangofthree.tarladan.modules.depot.dto.DepotCreateRequest;
import com.gangofthree.tarladan.modules.depot.dto.DepotResponse;
import com.gangofthree.tarladan.modules.depot.dto.DepotUpdateRequest;
import com.gangofthree.tarladan.modules.depot.service.DepotService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/depot")
@RequiredArgsConstructor
public class DepotController {

    private final DepotService depotService;

    // JWT'den depot owner ID alınıyor
    @PostMapping("/create")
    public ResponseEntity<DepotResponse> createDepot(
            @RequestBody DepotCreateRequest request,
            @RequestAttribute("domainId") Long depotOwnerId
    ) {
        DepotResponse response = depotService.createDepot(request, depotOwnerId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/all")
    public ResponseEntity<List<DepotResponse>> getAllDepots() {
        List<DepotResponse> depots = depotService.getAllDepots();
        return ResponseEntity.ok(depots);
    }

    @GetMapping("/{id}")
    public ResponseEntity<DepotResponse> getDepotById(@PathVariable Long id) {
        DepotResponse depot = depotService.getDepotById(id);
        return ResponseEntity.ok(depot);
    }

    @PutMapping("/update/{id}")
    public ResponseEntity<DepotResponse> updateDepot(
            @PathVariable Long id,
            @RequestBody DepotUpdateRequest request,
            @RequestAttribute("domainId") Long depotOwnerId
    ) {
        DepotResponse updatedDepot = depotService.updateDepot(id, request, depotOwnerId);
        return ResponseEntity.ok(updatedDepot);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteDepot(
            @PathVariable Long id,
            @RequestAttribute("domainId") Long depotOwnerId
    ) {
        depotService.deleteDepot(id, depotOwnerId);
        return ResponseEntity.ok("Depot with id " + id + " has been deleted successfully.");
    }

    // JWT kullanarak kendi depolarını listeleme
    @GetMapping("/my-depots")
    public ResponseEntity<List<DepotResponse>> getMyDepots(@RequestAttribute("domainId") Long depotOwnerId) {
        List<DepotResponse> depots = depotService.getDepotsByDepotOwner(depotOwnerId);
        return ResponseEntity.ok(depots);
    }
}
