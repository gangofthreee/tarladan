package com.gangofthree.tarladan.modules.product.dto;

import lombok.*;
import org.springframework.web.multipart.MultipartFile;

import java.math.BigInteger;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class AddProductRequest {
    private Long id_depot;      // client bunu göndermeye devam edecek
    private String name;
    private BigInteger quantity_kg;
    private BigInteger price_per_kg;
    private BigInteger min_buy;
    private MultipartFile photo;
}
