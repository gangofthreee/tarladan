package com.gangofthree.tarladan.modules.depotOwner.repository;

import com.gangofthree.tarladan.modules.depotOwner.entity.DepotOwner;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DepotOwnerRepository extends JpaRepository<DepotOwner, Long> {
}
