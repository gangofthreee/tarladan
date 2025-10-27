package com.gangofthree.tarladan.modules.depot.service;

import com.gangofthree.tarladan.modules.depot.dto.DepotCreateRequest;
import com.gangofthree.tarladan.modules.depot.dto.DepotResponse;
import com.gangofthree.tarladan.modules.depot.entity.Depot;
import com.gangofthree.tarladan.modules.depot.repository.DepotRepository;
import com.gangofthree.tarladan.modules.depotOwner.entity.DepotOwner;
import com.gangofthree.tarladan.modules.depotOwner.repository.DepotOwnerRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

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
}

