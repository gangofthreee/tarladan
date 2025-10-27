package com.gangofthree.tarladan.modules.depot.repository;
import org.springframework.data.jpa.repository.JpaRepository;
import com.gangofthree.tarladan.modules.depot.entity.Depot;

import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface DepotRepository extends JpaRepository<Depot, Long> {
    List<Depot> findAllByDepotOwner_Id(Long depotOwnerId);

}
