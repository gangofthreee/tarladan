package com.gangofthree.tarladan.modules.depot.service;

import com.gangofthree.tarladan.modules.depot.dto.DepotCreateRequest;
import com.gangofthree.tarladan.modules.depot.dto.DepotResponse;
import com.gangofthree.tarladan.modules.depot.dto.DepotUpdateRequest;

import java.util.List;

public interface DepotService {

    DepotResponse createDepot(DepotCreateRequest request, Long depotOwnerId);

    List<DepotResponse> getAllDepots();

    DepotResponse getDepotById(Long id);

    // Authorization is checked against the depotOwnerId derived from the JWT
    DepotResponse updateDepot(Long id, DepotUpdateRequest request, Long depotOwnerId);

    void deleteDepot(Long id, Long depotOwnerId);

    List<DepotResponse> getDepotsByDepotOwner(Long depotOwnerId);
}
