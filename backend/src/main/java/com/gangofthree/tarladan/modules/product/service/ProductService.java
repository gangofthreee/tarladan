package com.gangofthree.tarladan.modules.product.service;

import com.gangofthree.tarladan.modules.product.dto.AddProductRequest;
import com.gangofthree.tarladan.modules.product.entity.Product;


public interface ProductService {
    Product addProduct(AddProductRequest addProductRequest);
}

