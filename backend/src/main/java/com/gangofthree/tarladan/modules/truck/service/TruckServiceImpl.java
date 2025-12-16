package com.gangofthree.tarladan.modules.truck.service;

import com.gangofthree.tarladan.modules.truck.entity.Truck;
import com.gangofthree.tarladan.modules.trucker.entity.Trucker;
import com.gangofthree.tarladan.modules.truck.repository.TruckRepository;
import com.gangofthree.tarladan.modules.truck.dto.AddTruckRequest;
import com.gangofthree.tarladan.modules.truck.dto.UpdateTruckRequest;
import com.gangofthree.tarladan.modules.trucker.repository.TruckerRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import com.gangofthree.tarladan.modules.truck.dto.TruckResponse; 
import java.util.stream.Collectors; 

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;

@Service
@RequiredArgsConstructor
public class TruckServiceImpl implements TruckService {

    private final TruckRepository truckRepository;
    private final TruckerRepository truckerRepository;

    private static final String UPLOAD_DIR = "/app/uploads/truckPhotos/";

    private TruckResponse mapToResponse(Truck truck) {
        String truckerName = null;
        if (truck.getTrucker() != null && truck.getTrucker().getUser() != null) {
            String name = truck.getTrucker().getUser().getName();
            String surname = truck.getTrucker().getUser().getSurname();
            truckerName = (name != null ? name : "") + " " + (surname != null ? surname : "");
            truckerName = truckerName.trim();
        }
        
        return TruckResponse.builder()
                .id(truck.getId())
                .vehicle(truck.getVehicle())
                .capacityTon(truck.getCapacityTon()) 
                .imageUrl(truck.getImageUrl())
                .plate_number(truck.getPlate())
                .truckerId(truck.getTrucker() != null ? truck.getTrucker().getId() : null)
                .trucker_name(truckerName)
                .build();
    }

    @Override
    public Truck addTruck(AddTruckRequest addTruckRequest, Long truckerId) {
        try {
            Trucker trucker = truckerRepository.findById(truckerId)
                    .orElseThrow(() -> new IllegalArgumentException("Trucker not found"));

            if (truckRepository.findByPlate(addTruckRequest.getPlate()).isPresent()) {
                throw new IllegalArgumentException("Bu plaka zaten sistemde kayıtlı: " + addTruckRequest.getPlate());
            }

            // Önce truck'ı kaydet ki ID'sini alalım
            Truck truck = Truck.builder()
                    .trucker(trucker)
                    .vehicle(addTruckRequest.getVehicle())
                    .capacityTon(addTruckRequest.getCapacityTon())
                    .plate(addTruckRequest.getPlate())
//                    .basePrice(addTruckRequest.getBasePrice())
                    .build();
            
            truck = truckRepository.save(truck);

            // Şimdi truck ID'si ile dosya adı oluştur
            MultipartFile photo = addTruckRequest.getPhoto();
            String fileName = "truckPhoto_" + truck.getId() + "_" + System.currentTimeMillis();
            Path filePath = Paths.get(UPLOAD_DIR, fileName);
            Files.createDirectories(filePath.getParent());
            photo.transferTo(filePath.toFile());

            // imageUrl'i güncelle
            truck.setImageUrl("/uploads/truckPhotos/" + fileName);
            return truckRepository.save(truck);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    public Truck updateTruck(Long id, UpdateTruckRequest updateRequest, Long truckerId) {
        Truck existingTruck = truckRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Truck not found"));

        if (!existingTruck.getTrucker().getId().equals(truckerId)) {
            throw new SecurityException("Bu trucker'a ait olmayan aracı güncelleyemezsiniz.");
        }

        if (updateRequest.getPlate() != null &&
                !updateRequest.getPlate().equals(existingTruck.getPlate()) &&
                truckRepository.findByPlate(updateRequest.getPlate()).isPresent()) {
            throw new IllegalArgumentException("Bu plaka zaten sistemde kayıtlı: " + updateRequest.getPlate());
        }

        if (updateRequest.getVehicle() != null) existingTruck.setVehicle(updateRequest.getVehicle());
        if (updateRequest.getCapacityTon() != null) existingTruck.setCapacityTon(updateRequest.getCapacityTon());
//        if (updateRequest.getBasePrice() != null) existingTruck.setBasePrice(updateRequest.getBasePrice());
        if (updateRequest.getPlate() != null) existingTruck.setPlate(updateRequest.getPlate());

        MultipartFile newPhoto = updateRequest.getPhoto();
        if (newPhoto != null && !newPhoto.isEmpty()) {
            try {
                if (existingTruck.getImageUrl() != null) {
                    Path oldPath = Paths.get(UPLOAD_DIR,
                            Paths.get(existingTruck.getImageUrl()).getFileName().toString());
                    Files.deleteIfExists(oldPath);
                }

                String fileName = "truckPhoto_" + existingTruck.getId() + "_" + System.currentTimeMillis();
                Path newPath = Paths.get(UPLOAD_DIR, fileName);
                Files.createDirectories(newPath.getParent());
                newPhoto.transferTo(newPath.toFile());
                existingTruck.setImageUrl("/uploads/truckPhotos/" + fileName);

            } catch (IOException e) {
                throw new RuntimeException("Fotoğraf güncellenirken hata oluştu", e);
            }
        }

        return truckRepository.save(existingTruck);
    }

    @Override
    public void deleteTruck(Long id, Long truckerId) {
        Truck existingTruck = truckRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Truck not found"));

        if (!existingTruck.getTrucker().getId().equals(truckerId)) {
            throw new SecurityException("Bu trucker'a ait olmayan aracı silemezsiniz.");
        }

        if (existingTruck.getImageUrl() != null) {
            try {
                Path imagePath = Paths.get(UPLOAD_DIR,
                        Paths.get(existingTruck.getImageUrl()).getFileName().toString());
                Files.deleteIfExists(imagePath);
            } catch (IOException e) {
                throw new RuntimeException("Fotoğraf silinirken hata oluştu", e);
            }
        }

        truckRepository.delete(existingTruck);
    }

    @Override
    public List<TruckResponse> getTrucksByTruckerId(Long truckerId) {
        Trucker trucker = truckerRepository.findById(truckerId)
                .orElseThrow(() -> new EntityNotFoundException("Trucker bulunamadı."));
        return truckRepository.findAllByTrucker(trucker).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<TruckResponse> getAllTrucks() {
        return truckRepository.findAll().stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public TruckResponse getTruckByIdAndTrucker(Long id, Long truckerId) {
        Truck truck = truckRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Truck bulunamadı."));
        if (!truck.getTrucker().getId().equals(truckerId)) {
            throw new SecurityException("Bu trucker'a ait olmayan araca erişemezsiniz.");
        }
        return mapToResponse(truck);
    }

}