package com.gangofthree.tarladan.modules.depot.repository;
import org.springframework.data.jpa.repository.JpaRepository;
import com.gangofthree.tarladan.modules.depot.entity.Depot;

import org.springframework.stereotype.Repository;

@Repository
public interface DepotRepository extends JpaRepository<Depot, Long> {

}
