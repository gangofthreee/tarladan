package com.gangofthree.tarladan.modules.product.service;

import com.gangofthree.tarladan.modules.product.dto.AddProductRequest;
import com.gangofthree.tarladan.modules.farmer.entity.Farmer;
import com.gangofthree.tarladan.modules.product.entity.Product;
import com.gangofthree.tarladan.modules.farmer.repository.FarmerRepository;
import com.gangofthree.tarladan.modules.product.repository.ProductRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;
import java.math.BigInteger;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class ProductServiceImpl implements ProductService {

    private final ProductRepository productRepository;
    private final FarmerRepository farmerRepository;

    @Override
    public Product addProduct(AddProductRequest addProductRequest) {

        try {
            // Farmer'ı requestten gelen id ile getir
            Farmer farmer = farmerRepository.findById(addProductRequest.getId())
                    .orElseThrow(() -> new RuntimeException("Farmer not found with id: " + addProductRequest.getId()));

            // Fotoğrafı kaydet
            MultipartFile photo = addProductRequest.getPhoto();
            String uploadDir = "/app/uploads"; // Docker volume path
            String fileName = System.currentTimeMillis() + "_" + photo.getOriginalFilename();
            Path filePath = Paths.get(uploadDir, fileName);

            // Klasör yoksa oluştur
            Files.createDirectories(filePath.getParent());
            photo.transferTo(filePath.toFile());

            // Product entity oluştur
            Product product = new Product();
            product.setName(addProductRequest.getName());
            product.setQuantity_kg(addProductRequest.getQuantity_kg());
            product.setPrice_per_kg(addProductRequest.getPrice_per_kg());
            product.setMin_buy(addProductRequest.getMin_buy());
            product.setFarmer(farmer);
            //product.setCreated_ad(LocalDateTime.now());

            product.setImage_path("/app/uploads/" + fileName);

            // DB'ye kaydet
            return productRepository.save(product);

        } catch (IOException e) {
            throw new RuntimeException("Fotoğraf yükleme sırasında hata oluştu", e);
        }

    }

    @Override
    public Product updateProduct(Long id, Map<String, Object> updates) {

        //product'i getir
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Product not found with id: " + id));

        updates.forEach((key, value) -> {
            switch (key) {
                case "name" -> product.setName((String) value);
                case "quantity_kg" -> product.setQuantity_kg(new BigInteger(value.toString()));
                case "price_per_kg" -> product.setPrice_per_kg(new BigInteger(value.toString()));
                case "min_buy" -> product.setMin_buy(new BigInteger(value.toString()));
                case "image_path" -> product.setImage_path((String) value);
                default -> throw new IllegalArgumentException("Invalid field: " + key);
            }
        });

        return productRepository.save(product);
    }
}
