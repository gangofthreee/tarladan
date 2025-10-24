package com.gangofthree.tarladan.modules.product.service;

import com.gangofthree.tarladan.modules.product.dto.AddProductRequest;
import com.gangofthree.tarladan.modules.product.entity.Product;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;


public interface ProductService {
    Product addProduct(AddProductRequest addProductRequest);

    Product updateProduct(Long id, Map<String, Object> updates);
    
    Product updateProductWithMultipart(Long id, String name, String quantityKg, String pricePerKg, String minBuy, MultipartFile photo);

    Product deleteProduct(Long id);

    Product getProduct(Long id);

    List<Product> getProductsByFarmerId(Long farmerId);
}

