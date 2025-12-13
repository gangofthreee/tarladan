package com.gangofthree.tarladan.modules.product.service;

import com.gangofthree.tarladan.modules.product.dto.AddProductRequest;
import com.gangofthree.tarladan.modules.product.dto.ProductResponse;
import com.gangofthree.tarladan.modules.product.entity.Product;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;


public interface ProductService {
    Product addProduct(AddProductRequest addProductRequest, Long farmerId);

    Product updateProduct(Long id, Map<String, Object> updates, Long farmerId);

    Product updateProductWithMultipart(Long id, String name, String quantityKg, String pricePerKg, String minBuy, MultipartFile photo, Long farmerId);

    Product deleteProduct(Long id, Long farmerId);

    ProductResponse getProduct(Long id);

    List<ProductResponse> getProductsByFarmerId(Long farmerId);

    List<ProductResponse> getAllProducts();
}


