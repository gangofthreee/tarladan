package com.gangofthree.tarladan.modules.farmer.repository;

import com.gangofthree.tarladan.modules.farmer.entity.Farmer;
import org.springframework.data.jpa.repository.JpaRepository;

public interface FarmerRepository extends JpaRepository<Farmer, Long> {

}
