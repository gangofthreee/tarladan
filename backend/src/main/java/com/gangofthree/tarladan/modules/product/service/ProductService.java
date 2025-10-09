package com.gangofthree.tarladan.modules.product.service;

import com.gangofthree.tarladan.modules.product.dto.AddProductRequest;
import com.gangofthree.tarladan.modules.product.entity.Product;

import java.util.Map;


public interface ProductService {
    Product addProduct(AddProductRequest addProductRequest);

    Product updateProduct(Long id, Map<String, Object> updates);
}

