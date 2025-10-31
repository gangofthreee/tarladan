package com.gangofthree.tarladan.modules.trucker.repository;

import com.gangofthree.tarladan.modules.trucker.entity.Trucker;
import org.springframework.data.jpa.repository.JpaRepository;


public interface TruckerRepository extends JpaRepository<Trucker, Long> {
}
