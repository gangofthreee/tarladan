package com.gangofthree.tarladan.modules.product.service;

import com.gangofthree.tarladan.modules.depot.entity.Depot;
import com.gangofthree.tarladan.modules.depot.repository.DepotRepository;
import com.gangofthree.tarladan.modules.product.dto.AddProductRequest;
import com.gangofthree.tarladan.modules.farmer.entity.Farmer;
import com.gangofthree.tarladan.modules.product.entity.Product;
import com.gangofthree.tarladan.modules.farmer.repository.FarmerRepository;
import com.gangofthree.tarladan.modules.product.repository.ProductRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import com.gangofthree.tarladan.modules.product.dto.ProductResponse;
import java.util.stream.Collectors;

import java.io.IOException;
import java.math.BigInteger;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class ProductServiceImpl implements ProductService {

    // Filesystem directory the photo is written to.
    private static final String PRODUCT_PHOTO_UPLOAD_DIR = "/app/uploads/productPhotos";
    // Public URL prefix the photo is served from (see WebConfig's "/uploads/**" resource handler).
    private static final String PRODUCT_PHOTO_URL_PREFIX = "/uploads/productPhotos/";

    private final ProductRepository productRepository;
    private final FarmerRepository farmerRepository;
    private final DepotRepository depotRepository;

    // --- Helper method: Entity -> DTO conversion ---
    private ProductResponse mapToResponse(Product product) {
        String farmerName = null;
        if (product.getFarmer() != null && product.getFarmer().getUser() != null) {
            String name = product.getFarmer().getUser().getName();
            String surname = product.getFarmer().getUser().getSurname();
            farmerName = (name != null ? name : "") + " " + (surname != null ? surname : "");
            farmerName = farmerName.trim();
        }
        
        return ProductResponse.builder()
                .id(product.getId())
                .name(product.getName())
                .quantity_kg(product.getQuantity_kg())
                .price_per_kg(product.getPrice_per_kg())
                .min_buy(product.getMin_buy())
                .image_path(product.getImage_path())
                .depot_id(product.getDepot() != null ? product.getDepot().getId() : null)
                .farmer_id(product.getFarmer() != null ? product.getFarmer().getId() : null)
                .farmer_name(farmerName)
                .depot_latitude(product.getDepot() != null ? product.getDepot().getLatitude() : null)
                .depot_longitude(product.getDepot() != null ? product.getDepot().getLongitude() : null)
                .build();
    }

    @Override
    @Transactional
    public Product addProduct(AddProductRequest addProductRequest, Long farmerId) {
        try {
            // Look up the Farmer using the JWT domainId
            Farmer farmer = farmerRepository.findById(farmerId)
                    .orElseThrow(() -> new RuntimeException("Farmer not found with id: " + farmerId));

            // Depot check
            Depot depot = depotRepository.findById(addProductRequest.getId_depot())
                    .orElseThrow(() -> new SecurityException("Depot not found with id: " + addProductRequest.getId_depot()));

            // Build the Product entity (save first so we get an ID to name the photo file with)
            Product product = new Product();
            product.setName(addProductRequest.getName());
            product.setQuantity_kg(addProductRequest.getQuantity_kg());
            product.setPrice_per_kg(addProductRequest.getPrice_per_kg());
            product.setMin_buy(addProductRequest.getMin_buy());
            product.setFarmer(farmer);
            product.setDepot(depot);

            // Save the product first so we have its ID
            Product savedProduct = productRepository.save(product);

            // Save the photo keyed by productId
            MultipartFile photo = addProductRequest.getPhoto();
            if (photo != null && !photo.isEmpty()) {
                String extension = extractExtension(photo.getOriginalFilename());
                String fileName = "product_" + savedProduct.getId() + "_" + System.currentTimeMillis() + extension;
                Path filePath = Paths.get(PRODUCT_PHOTO_UPLOAD_DIR, fileName);

                Files.createDirectories(filePath.getParent());
                photo.transferTo(filePath.toFile());

                // Update the image path to the public URL (served via WebConfig's "/uploads/**" handler)
                savedProduct.setImage_path(PRODUCT_PHOTO_URL_PREFIX + fileName);
                productRepository.save(savedProduct);
            }

            return savedProduct;

        } catch (IOException e) {
            throw new RuntimeException("Failed to upload photo", e);
        }
    }

    private String extractExtension(String originalFilename) {
        if (originalFilename == null) {
            return "";
        }
        int dotIndex = originalFilename.lastIndexOf('.');
        return dotIndex >= 0 ? originalFilename.substring(dotIndex) : "";
    }


    @Override
    @Transactional
    public Product updateProduct(Long id, Map<String, Object> updates, Long farmerId) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Product not found with id: " + id));

        // JWT domainId ownership check
        if (!product.getFarmer().getId().equals(farmerId)) {
            throw new SecurityException("You are not authorized to modify this product.");
        }

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

    @Override
    @Transactional
    public Product updateProductWithMultipart(Long id, String name, String quantityKg, String pricePerKg, String minBuy, MultipartFile photo, Long farmerId) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Product not found with id: " + id));

        // JWT domainId ownership check
        if (!product.getFarmer().getId().equals(farmerId)) {
            throw new SecurityException("You are not authorized to modify this product.");
        }

        try {
            if (name != null && !name.isEmpty()) {
                product.setName(name);
            }
            if (quantityKg != null && !quantityKg.isEmpty()) {
                product.setQuantity_kg(new BigInteger(quantityKg));
            }
            if (pricePerKg != null && !pricePerKg.isEmpty()) {
                product.setPrice_per_kg(new BigInteger(pricePerKg));
            }
            if (minBuy != null && !minBuy.isEmpty()) {
                product.setMin_buy(new BigInteger(minBuy));
            }

            if (photo != null && !photo.isEmpty()) {
                String fileName = System.currentTimeMillis() + "_" + photo.getOriginalFilename();
                Path filePath = Paths.get(PRODUCT_PHOTO_UPLOAD_DIR, fileName);

                Files.createDirectories(filePath.getParent());
                photo.transferTo(filePath.toFile());

                // Store the public URL the photo is served from (matches where it was written above)
                product.setImage_path(PRODUCT_PHOTO_URL_PREFIX + fileName);
            }

            return productRepository.save(product);
        } catch (IOException e) {
            throw new RuntimeException("Failed to update photo", e);
        }
    }

    @Override
    @Transactional
    public Product deleteProduct(Long id, Long farmerId) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Product not found with id: " + id));

        // JWT domainId ownership check
        if (!product.getFarmer().getId().equals(farmerId)) {
            throw new SecurityException("You are not authorized to delete this product.");
        }

        productRepository.delete(product);
        return product;
    }

    @Override
    @Transactional(readOnly = true)
    public ProductResponse getProduct(Long id) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Product not found with id: " + id));
        return mapToResponse(product);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ProductResponse> getProductsByFarmerId(Long farmerId) {
        List<Product> products = productRepository.findByFarmerIdWithDetails(farmerId);
        return products.stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }


    @Override
    @Transactional(readOnly = true)
    public List<ProductResponse> getAllProducts() {
        List<Product> products = productRepository.findAllWithDetails();
        return products.stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }
}
