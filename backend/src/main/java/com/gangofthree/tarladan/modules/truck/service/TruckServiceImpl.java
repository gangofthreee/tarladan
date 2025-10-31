package com.gangofthree.tarladan.modules.truck.service;

import com.gangofthree.tarladan.modules.truck.entity.Truck;
import com.gangofthree.tarladan.modules.trucker.entity.Trucker;
import com.gangofthree.tarladan.modules.truck.repository.TruckRepository;
import com.gangofthree.tarladan.modules.truck.dto.AddTruckRequest;
import com.gangofthree.tarladan.modules.trucker.repository.TruckerRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

@Service
@RequiredArgsConstructor
public class TruckServiceImpl implements TruckService {

    private final TruckRepository truckRepository;
    private final TruckerRepository truckerRepository;

    private static final String UPLOAD_DIR = "/app/uploads/truckPhotos/";

    @Override
    public Truck addTruck(AddTruckRequest addTruckRequest) {
        try{
            Trucker trucker = truckerRepository.findById(addTruckRequest.getTruckerId())
                    .orElseThrow(() -> new IllegalArgumentException("Trucker not found"));

            if (truckRepository.findByPlate(addTruckRequest.getPlate()).isPresent()) {
                throw new IllegalArgumentException("Bu plaka zaten sistemde kayıtlı: " + addTruckRequest.getPlate());
            }

            MultipartFile photo = addTruckRequest.getPhoto();

            String fileName = "truckPhoto_" + addTruckRequest.getTruckerId();
            Path filePath = Paths.get(UPLOAD_DIR, fileName);

            Files.createDirectories(filePath.getParent());
            photo.transferTo(filePath.toFile());

            Truck truck = Truck.builder()
                    .trucker(trucker)
                    .vehicle(addTruckRequest.getVehicle())
                    .capacityTon(addTruckRequest.getCapacityTon())
                    .plate(addTruckRequest.getPlate())
                    .basePrice(addTruckRequest.getBasePrice())
                    .imageUrl("/uploads/" + fileName)
                    .build();

            return truckRepository.save(truck);
        }
        catch (IOException e){
            throw new RuntimeException(e);
        }
    }
}
