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
    public DepotResponse createDepot(DepotCreateRequest request) {
        // DepotOwner kontrolü
        DepotOwner depotOwner = depotOwnerRepository.findById(request.getDepoOwnerId())
                .orElseThrow(() -> new IllegalArgumentException("Depot owner not found with id: " + request.getDepoOwnerId()));

        // Yeni Depot oluştur
        Depot depot = Depot.builder()
                .depotOwner(depotOwner)
                .address(request.getAddress())
                .sizeM2(request.getSizeM2())
                .capacityTon(request.getCapacityTon())
                .price(request.getPrice())
                .build();

        Depot savedDepot = depotRepository.save(depot);

        // Response döndür
        return DepotResponse.builder()
                .id(savedDepot.getId())
                .address(savedDepot.getAddress())
                .sizeM2(savedDepot.getSizeM2())
                .capacityTon(savedDepot.getCapacityTon())
                .price(savedDepot.getPrice())
                .depotOwnerId(savedDepot.getDepotOwner().getId())
                .build();
    }

    public List<DepotResponse> getAllDepots() {
        List<Depot> depots = depotRepository.findAll();

        return depots.stream()
                .map(depot -> DepotResponse.builder()
                        .id(depot.getId())
                        .depotOwnerId(depot.getDepotOwner().getId())
                        .address(depot.getAddress())
                        .sizeM2(depot.getSizeM2())
                        .capacityTon(depot.getCapacityTon())
                        .price(depot.getPrice())
                        .build())
                .collect(Collectors.toList());
    }

    @Override
    public DepotResponse getDepotById(Long id) {
        Depot depot = depotRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Depot not found with id: " + id));

        return convertToResponse(depot);
    }

    @Override
    public DepotResponse updateDepot(Long id, DepotUpdateRequest request) {
        Depot depot = depotRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Depot not found with id: " + id));

        // Kısmi güncelleme (null değilse güncelle)
        if (request.getAddress() != null) {
            depot.setAddress(request.getAddress());
        }
        if (request.getSizeM2() != null) {
            depot.setSizeM2(request.getSizeM2());
        }
        if (request.getCapacityTon() != null) {
            depot.setCapacityTon(request.getCapacityTon());
        }
        if (request.getPrice() != null) {
            depot.setPrice(request.getPrice());
        }

        Depot updatedDepot = depotRepository.save(depot);
        return convertToResponse(updatedDepot);
    }

    @Override
    public void deleteDepot(Long id) {
        Depot depot = depotRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Depot not found with id: " + id));
        depotRepository.delete(depot);
    }

    @Override
    public List<DepotResponse> getDepotsByDepotOwner(Long depotOwnerId) {
        List<Depot> depots = depotRepository.findAllByDepotOwner_Id(depotOwnerId);

        return depots.stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
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

