package com.gangofthree.tarladan.modules.product.controller;


import com.gangofthree.tarladan.modules.product.dto.AddProductRequest;
import com.gangofthree.tarladan.modules.product.entity.Product;
import com.gangofthree.tarladan.modules.product.service.ProductService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/farmer/product")
@RequiredArgsConstructor
public class ProductController {
    private final ProductService productService;

    @PostMapping(value = "/create", consumes = {"multipart/form-data"})
    public ResponseEntity<Product> createProduct(
            @RequestPart("id") String id,
            @RequestPart("name") String name,
            @RequestPart("quantity_kg") String quantityKg,
            @RequestPart("price_per_kg") String pricePerKg,
            @RequestPart("min_buy") String minBuy,
            @RequestPart("photo") MultipartFile photo
    ) {
        AddProductRequest request = new AddProductRequest();
        request.setId(Long.parseLong(id));
        request.setName(name);
        request.setQuantity_kg(new java.math.BigInteger(quantityKg));
        request.setPrice_per_kg(new java.math.BigInteger(pricePerKg));
        request.setMin_buy(new java.math.BigInteger(minBuy));
        request.setPhoto(photo);

        Product createdProduct = productService.addProduct(request);
        return ResponseEntity.ok(createdProduct);
    }
}
