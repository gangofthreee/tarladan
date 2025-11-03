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

    @Override
    public Truck addTruck(AddTruckRequest addTruckRequest) {
        try {
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
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    public Truck updateTruck(Long id, UpdateTruckRequest updateRequest) {
        Truck existingTruck = truckRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Truck not found"));

        // Eğer yeni plaka geldiyse ve farklı bir truck’ta varsa hata ver
        if (updateRequest.getPlate() != null &&
                !updateRequest.getPlate().equals(existingTruck.getPlate()) &&
                truckRepository.findByPlate(updateRequest.getPlate()).isPresent()) {
            throw new IllegalArgumentException("Bu plaka zaten sistemde kayıtlı: " + updateRequest.getPlate());
        }

        if (updateRequest.getVehicle() != null) {
            existingTruck.setVehicle(updateRequest.getVehicle());
        }
        if (updateRequest.getCapacityTon() != null) {
            existingTruck.setCapacityTon(updateRequest.getCapacityTon());
        }
        if (updateRequest.getBasePrice() != null) {
            existingTruck.setBasePrice(updateRequest.getBasePrice());
        }
        if (updateRequest.getPlate() != null) {
            existingTruck.setPlate(updateRequest.getPlate());
        }

        // Fotoğraf güncellenecekse
        MultipartFile newPhoto = updateRequest.getPhoto();
        if (newPhoto != null && !newPhoto.isEmpty()) {
            try {
                // Eski fotoğraf varsa sil
                if (existingTruck.getImageUrl() != null) {
                    Path oldPath = Paths.get(UPLOAD_DIR,
                            Paths.get(existingTruck.getImageUrl()).getFileName().toString());
                    Files.deleteIfExists(oldPath);
                }

//                String extension = getFileExtension(newPhoto.getOriginalFilename());
                String fileName = "truckPhoto_" + existingTruck.getId();
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
    public void deleteTruck(Long id) {
        Truck existingTruck = truckRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Truck not found"));

        // Eğer fotoğraf varsa dosyayı sil
        if (existingTruck.getImageUrl() != null) {
            try {
                // imageUrl: /uploads/truckPhotos/truckPhoto_{id}.jpg
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
    public List<Truck> getAllTrucks() {
        return truckRepository.findAll();
    }

    // --- Belirli Trucker'a Ait Tırları Getirme ---
    @Override
    public List<Truck> getTrucksByTruckerId(Long truckerId) {
        Trucker trucker = truckerRepository.findById(truckerId)
                .orElseThrow(() -> new EntityNotFoundException("ID " + truckerId + " ile Trucker bulunamadı."));

        return truckRepository.findAllByTrucker(trucker);
    }

    @Override
    public Truck getTruckById(Long id) {
        return truckRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("ID " + id + " ile Truck bulunamadı."));
    }
}