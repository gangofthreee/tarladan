package com.gangofthree.tarladan.modules.trucker.repository;

import com.gangofthree.tarladan.modules.trucker.entity.Trucker;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;


public interface TruckerRepository extends JpaRepository<Trucker, Long> {
    Optional<Trucker> findByUser_Id(Long userId);

}
