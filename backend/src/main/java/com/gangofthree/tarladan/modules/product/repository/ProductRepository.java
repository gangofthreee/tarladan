package com.gangofthree.tarladan.modules.product.repository;

import com.gangofthree.tarladan.modules.product.entity.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {

    // Fetch-joins the associations used by ProductServiceImpl#mapToResponse so that
    // listing endpoints don't trigger an N+1 query per product.
    @Query("SELECT p FROM Product p " +
            "LEFT JOIN FETCH p.farmer f " +
            "LEFT JOIN FETCH f.user " +
            "LEFT JOIN FETCH p.depot")
    List<Product> findAllWithDetails();

    @Query("SELECT p FROM Product p " +
            "LEFT JOIN FETCH p.farmer f " +
            "LEFT JOIN FETCH f.user " +
            "LEFT JOIN FETCH p.depot " +
            "WHERE p.farmer.id = :farmerId")
    List<Product> findByFarmerIdWithDetails(@Param("farmerId") Long farmerId);
}

