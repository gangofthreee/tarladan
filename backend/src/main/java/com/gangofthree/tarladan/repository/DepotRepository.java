package com.gangofthree.tarladan.repository;
import org.springframework.data.jpa.repository.JpaRepository;
import com.gangofthree.tarladan.entity.Depot;

import org.springframework.stereotype.Repository;

@Repository
public interface DepotRepository extends JpaRepository<Depot, Long> {

}
