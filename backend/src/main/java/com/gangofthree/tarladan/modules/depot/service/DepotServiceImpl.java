package com.gangofthree.tarladan.modules.depot.service;

import com.gangofthree.tarladan.modules.depot.dto.DepotCreateRequest;
import com.gangofthree.tarladan.modules.depot.dto.DepotResponse;
import com.gangofthree.tarladan.modules.depot.dto.DepotUpdateRequest;
import com.gangofthree.tarladan.modules.depot.entity.Depot;
import com.gangofthree.tarladan.modules.depot.repository.DepotRepository;
import com.gangofthree.tarladan.modules.depotOwner.entity.DepotOwner;
import com.gangofthree.tarladan.modules.depotOwner.repository.DepotOwnerRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DepotServiceImpl implements DepotService {

    private final DepotRepository depotRepository;
    private final DepotOwnerRepository depotOwnerRepository;

    @Override
    public DepotResponse createDepot(DepotCreateRequest request, Long depotOwnerId) {
        DepotOwner depotOwner = depotOwnerRepository.findById(depotOwnerId)
                .orElseThrow(() -> new IllegalArgumentException("Depot owner not found with id: " + depotOwnerId));

        Depot depot = Depot.builder()
                .depotOwner(depotOwner)
                .address(request.getAddress())
                .sizeM2(request.getSizeM2())
                .capacityTon(request.getCapacityTon())
                .price(request.getPrice())
                .build();

        Depot savedDepot = depotRepository.save(depot);

        return convertToResponse(savedDepot);
    }

    @Override
    public List<DepotResponse> getAllDepots() {
        List<Depot> depots = depotRepository.findAll();
        return depots.stream().map(this::convertToResponse).collect(Collectors.toList());
    }

    @Override
    public DepotResponse getDepotById(Long id) {
        Depot depot = depotRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Depot not found with id: " + id));
        return convertToResponse(depot);
    }

    @Override
    public DepotResponse updateDepot(Long id, DepotUpdateRequest request, Long depotOwnerId) {
        Depot depot = depotRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Depot not found with id: " + id));

        // JWT'den gelen owner id ile depot owner id eşleşiyor mu kontrolü
        if (!depot.getDepotOwner().getId().equals(depotOwnerId)) {
            throw new SecurityException("You are not authorized to update this depot.");
        }

        if (request.getAddress() != null) depot.setAddress(request.getAddress());
        if (request.getSizeM2() != null) depot.setSizeM2(request.getSizeM2());
        if (request.getCapacityTon() != null) depot.setCapacityTon(request.getCapacityTon());
        if (request.getPrice() != null) depot.setPrice(request.getPrice());

        Depot updatedDepot = depotRepository.save(depot);
        return convertToResponse(updatedDepot);
    }


    @Override
    public void deleteDepot(Long id, Long depotOwnerId) {
        Depot depot = depotRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Depot not found with id: " + id));

        if (!depot.getDepotOwner().getId().equals(depotOwnerId)) {
            throw new SecurityException("You are not authorized to delete this depot.");
        }

        depotRepository.delete(depot);
    }


    @Override
    public List<DepotResponse> getDepotsByDepotOwner(Long depotOwnerId) {
        List<Depot> depots = depotRepository.findAllByDepotOwner_Id(depotOwnerId);
        return depots.stream().map(this::convertToResponse).collect(Collectors.toList());
    }

    private DepotResponse convertToResponse(Depot depot) {
        return DepotResponse.builder()
                .id(depot.getId())
                .depotOwnerId(depot.getDepotOwner().getId())
                .address(depot.getAddress())
                .sizeM2(depot.getSizeM2())
                .capacityTon(depot.getCapacityTon())
                .price(depot.getPrice())
                .build();
    }
}
