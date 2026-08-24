package com.gangofthree.tarladan.modules.order.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class OrderCreateRequest {
    @NotNull(message = "Ürün seçilmelidir.")
    private Long productId;

    @NotNull(message = "Depo seçilmelidir.")
    private Long depotId;

    @NotNull(message = "Kamyon seçilmelidir.")
    private Long truckId;

    private String locFrom;
    private String locTo;

    @NotNull(message = "Miktar boş bırakılamaz.")
    @Min(value = 1, message = "Miktar 0'dan büyük olmalıdır.")
    private Integer quantityKg;
}


