package com.gangofthree.tarladan.modules.product.controller;


import com.gangofthree.tarladan.modules.product.dto.AddProductRequest;
import com.gangofthree.tarladan.modules.product.entity.Product;
import com.gangofthree.tarladan.modules.product.service.ProductService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import com.gangofthree.tarladan.modules.product.dto.ProductResponse; 


import java.math.BigInteger;
import java.util.List;

@RestController
@RequestMapping("/farmer/product")
@RequiredArgsConstructor
public class ProductController {

    private final ProductService productService;

    @CacheEvict(value = "products", allEntries = true)
    @PostMapping(value = "/create", consumes = {"multipart/form-data"})
    public ResponseEntity<Product> createProduct(
            @RequestPart("name") String name,
            @RequestPart("quantity_kg") String quantityKg,
            @RequestPart("price_per_kg") String pricePerKg,
            @RequestPart("min_buy") String minBuy,
            @RequestPart("photo") MultipartFile photo,
            @RequestPart("id_depot") String depotId,
            @RequestAttribute("domainId") Long farmerId  // comes from JWT
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

    @CacheEvict(value = "products", allEntries = true)
    @PatchMapping(value = "/update/{id}", consumes = {"multipart/form-data"})
    public ResponseEntity<Product> updateProduct(
            @PathVariable Long id,
            @RequestPart(value = "name", required = false) String name,
            @RequestPart(value = "quantity_kg", required = false) String quantityKg,
            @RequestPart(value = "price_per_kg", required = false) String pricePerKg,
            @RequestPart(value = "min_buy", required = false) String minBuy,
            @RequestPart(value = "photo", required = false) MultipartFile photo,
            @RequestAttribute("domainId") Long farmerId  // comes from JWT
    ) {
        Product updatedProduct = productService.updateProductWithMultipart(id, name, quantityKg, pricePerKg, minBuy, photo, farmerId);
        return ResponseEntity.ok(updatedProduct);
    }

    @CacheEvict(value = "products", allEntries = true)
    @DeleteMapping("/delete/{id}")
    public ResponseEntity<Product> deleteProduct(
            @PathVariable Long id,
            @RequestAttribute("domainId") Long farmerId  // comes from JWT
    ){
        Product deletedProduct = productService.deleteProduct(id, farmerId);
        return ResponseEntity.ok(deletedProduct);
    }

    @Cacheable(value = "products", key = "#id")
    @GetMapping("/get/{id}")
    public ProductResponse getProduct(@PathVariable Long id) {
        ProductResponse product = productService.getProduct(id);
        return product;
    }

    @Cacheable(value = "products", key = "'my_products_' + #farmerId")
    @GetMapping("/my-products")
    public List<ProductResponse> getMyProducts(@RequestAttribute("domainId") Long farmerId) {
        List<ProductResponse> products = productService.getProductsByFarmerId(farmerId);
        return products;
    }

    @Cacheable(value = "products", key = "'all'")
    @GetMapping("/all_products")
    public List<ProductResponse> getAllProducts() {
        List<ProductResponse> products = productService.getAllProducts();
        return products;
    }


}