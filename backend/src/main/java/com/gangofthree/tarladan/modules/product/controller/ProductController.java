package com.gangofthree.tarladan.modules.product.controller;


import com.gangofthree.tarladan.modules.product.dto.AddProductRequest;
import com.gangofthree.tarladan.modules.product.entity.Product;
import com.gangofthree.tarladan.modules.product.service.ProductService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.math.BigInteger;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/farmer/product")
@RequiredArgsConstructor
public class ProductController {

    private final ProductService productService;

    @PostMapping(value = "/create", consumes = {"multipart/form-data"})
    public ResponseEntity<Product> createProduct(
            @RequestPart("name") String name,
            @RequestPart("quantity_kg") String quantityKg,
            @RequestPart("price_per_kg") String pricePerKg,
            @RequestPart("min_buy") String minBuy,
            @RequestPart("photo") MultipartFile photo,
            @RequestPart("id_depot") String depotId,
            @RequestAttribute("domainId") Long farmerId  // JWT’den geliyor
    ) {
        AddProductRequest request = new AddProductRequest();
        request.setName(name);
        request.setQuantity_kg(new BigInteger(quantityKg));
        request.setPrice_per_kg(new BigInteger(pricePerKg));
        request.setMin_buy(new BigInteger(minBuy));
        request.setPhoto(photo);
        request.setId_depot(Long.parseLong(depotId));

        Product createdProduct = productService.addProduct(request, farmerId);
        return ResponseEntity.ok(createdProduct);
    }


    @PatchMapping(value = "/update/{id}", consumes = {"multipart/form-data"})
    public ResponseEntity<Product> updateProduct(
            @PathVariable Long id,
            @RequestPart(value = "name", required = false) String name,
            @RequestPart(value = "quantity_kg", required = false) String quantityKg,
            @RequestPart(value = "price_per_kg", required = false) String pricePerKg,
            @RequestPart(value = "min_buy", required = false) String minBuy,
            @RequestPart(value = "photo", required = false) MultipartFile photo,
            @RequestAttribute("domainId") Long farmerId  // JWT’den geliyor
    ) {
        Product updatedProduct = productService.updateProductWithMultipart(id, name, quantityKg, pricePerKg, minBuy, photo, farmerId);
        return ResponseEntity.ok(updatedProduct);
    }

    @DeleteMapping("/delete/{id}")
    public ResponseEntity<Product> deleteProduct(
            @PathVariable Long id,
            @RequestAttribute("domainId") Long farmerId  // JWT’den geliyor
    ){
        Product deletedProduct = productService.deleteProduct(id, farmerId);
        return ResponseEntity.ok(deletedProduct);
    }

    @GetMapping("/get/{id}")
    public ResponseEntity<Product> getProduct(@PathVariable Long id) {
        Product product = productService.getProduct(id);
        return ResponseEntity.ok(product);
    }

    @GetMapping("/my-products")
    public ResponseEntity<List<Product>> getMyProducts(@RequestAttribute("domainId") Long farmerId) {
        List<Product> products = productService.getProductsByFarmerId(farmerId);
        return ResponseEntity.ok(products);
    }




}
