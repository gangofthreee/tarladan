package com.gangofthree.tarladan.modules.depot.controller;

import com.gangofthree.tarladan.modules.depot.dto.DepotCreateRequest;
import com.gangofthree.tarladan.modules.depot.dto.DepotResponse;
import com.gangofthree.tarladan.modules.depot.dto.DepotUpdateRequest;
import com.gangofthree.tarladan.modules.depot.service.DepotService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;

import java.util.List;

@RestController
@RequestMapping("/depot")
@RequiredArgsConstructor
public class DepotController {

    private final DepotService depotService;

    // The depot owner ID is derived from the JWT
    @CacheEvict(value = "depots", allEntries = true) // clear everything in the "depots" cache on CREATE, UPDATE, DELETE
    @PostMapping("/create")
    public ResponseEntity<DepotResponse> createDepot(
            @RequestBody DepotCreateRequest request,
            @RequestAttribute("domainId") Long depotOwnerId
    ) {
        DepotResponse response = depotService.createDepot(request, depotOwnerId);
        return ResponseEntity.ok(response);
    }

    @Cacheable(value = "depots", key = "'all'")
    @GetMapping("/all")
    public List<DepotResponse> getAllDepots() {
        List<DepotResponse> depots = depotService.getAllDepots();
        return depots;
    }

    @Cacheable(value = "depots", key = "#id")
    @GetMapping("/{id}")
    public DepotResponse getDepotById(@PathVariable Long id) {
        DepotResponse depot = depotService.getDepotById(id);
        return depot;
    }

    @CacheEvict(value = "depots", allEntries = true)
    @PutMapping("/update/{id}")
    public ResponseEntity<DepotResponse> updateDepot(
            @PathVariable Long id,
            @RequestBody DepotUpdateRequest request,
            @RequestAttribute("domainId") Long depotOwnerId
    ) {
        DepotResponse updatedDepot = depotService.updateDepot(id, request, depotOwnerId);
        return ResponseEntity.ok(updatedDepot);
    }

    @CacheEvict(value = "depots", allEntries = true)
    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteDepot(
            @PathVariable Long id,
            @RequestAttribute("domainId") Long depotOwnerId
    ) {
        depotService.deleteDepot(id, depotOwnerId);
        return ResponseEntity.ok("Depot with id " + id + " has been deleted successfully.");
    }

    @Cacheable(value = "depots", key = "'my_depots_' + #depotOwnerId")
    @GetMapping("/my-depots")
    public List<DepotResponse> getMyDepots(@RequestAttribute("domainId") Long depotOwnerId) {
        List<DepotResponse> depots = depotService.getDepotsByDepotOwner(depotOwnerId);
        return depots;
    }
}