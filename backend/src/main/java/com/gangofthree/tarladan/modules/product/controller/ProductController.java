package com.gangofthree.tarladan.modules.product.controller;


import com.gangofthree.tarladan.modules.product.dto.AddProductRequest;
import com.gangofthree.tarladan.modules.product.entity.Product;
import com.gangofthree.tarladan.modules.product.service.ProductService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

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

    @PatchMapping(value = "/update/{id}", consumes = {"multipart/form-data"})
    public ResponseEntity<Product> updateProduct(
            @PathVariable Long id,
            @RequestPart(value = "name", required = false) String name,
            @RequestPart(value = "quantity_kg", required = false) String quantityKg,
            @RequestPart(value = "price_per_kg", required = false) String pricePerKg,
            @RequestPart(value = "min_buy", required = false) String minBuy,
            @RequestPart(value = "photo", required = false) MultipartFile photo
    ) {
        Product updatedProduct = productService.updateProductWithMultipart(id, name, quantityKg, pricePerKg, minBuy, photo);
        return ResponseEntity.ok(updatedProduct);
    }

    @DeleteMapping("/delete/{id}")
    public ResponseEntity<Product> deleteProduct(
            @PathVariable Long id
    ){
        Product deletedProduct = productService.deleteProduct(id);
        return ResponseEntity.ok(deletedProduct);
    }

    @GetMapping("/get/{id}")
    public ResponseEntity<Product> getProduct(@PathVariable Long id) {
        Product product = productService.getProduct(id);
        return ResponseEntity.ok(product);
    }

    @GetMapping("/getFarmerProduct/{id}")
    public ResponseEntity<List<Product>> getFarmerProducts(@PathVariable("id") Long farmerId) {
        List<Product> products = productService.getProductsByFarmerId(farmerId);
        return ResponseEntity.ok(products);
    }



}
