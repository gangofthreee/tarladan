package com.gangofthree.tarladan.modules.farmer.repository;

import com.gangofthree.tarladan.modules.farmer.entity.Farmer;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface FarmerRepository extends JpaRepository<Farmer, Long> {
    Optional<Farmer> findByUser_Id(Long userId);
}
