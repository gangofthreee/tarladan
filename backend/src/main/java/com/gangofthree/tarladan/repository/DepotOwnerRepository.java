package com.gangofthree.tarladan.repository;

import com.gangofthree.tarladan.entity.DepotOwner;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DepotOwnerRepository extends JpaRepository<DepotOwner, Long> {
}
