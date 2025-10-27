package com.gangofthree.tarladan.modules.depot.service;

import com.gangofthree.tarladan.modules.depot.dto.DepotCreateRequest;
import com.gangofthree.tarladan.modules.depot.dto.DepotResponse;

import java.util.List;

public interface DepotService {
    DepotResponse createDepot(DepotCreateRequest request);
    List<DepotResponse> getAllDepots();
    DepotResponse getDepotById(Long id);

}

