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

    @PostMapping("/create")
    public ResponseEntity<DepotResponse> createDepot(@RequestBody DepotCreateRequest request) {
        DepotResponse response = depotService.createDepot(request);
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
            @RequestBody DepotUpdateRequest request
    ) {
        DepotResponse updatedDepot = depotService.updateDepot(id, request);
        return ResponseEntity.ok(updatedDepot);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteDepot(@PathVariable Long id) {
        depotService.deleteDepot(id);
        return ResponseEntity.ok("Depot with id " + id + " has been deleted successfully.");
    }

    @GetMapping("/owner/{depotOwnerId}")
    public ResponseEntity<List<DepotResponse>> getDepotsByDepotOwner(@PathVariable Long depotOwnerId) {
        return ResponseEntity.ok(depotService.getDepotsByDepotOwner(depotOwnerId));
    }
}

