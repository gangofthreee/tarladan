package com.gangofthree.tarladan.modules.depot.service;

import com.gangofthree.tarladan.modules.depot.dto.DepotCreateRequest;
import com.gangofthree.tarladan.modules.depot.dto.DepotResponse;
import com.gangofthree.tarladan.modules.depot.dto.DepotUpdateRequest;

import java.util.List;

public interface DepotService {
    DepotResponse createDepot(DepotCreateRequest request);
    List<DepotResponse> getAllDepots();
    DepotResponse getDepotById(Long id);
    DepotResponse updateDepot(Long id, DepotUpdateRequest request);
    void deleteDepot(Long id);
    List<DepotResponse> getDepotsByDepotOwner(Long depotOwnerId);

}

