package com.gangofthree.tarladan.modules.customer.repository;

import com.gangofthree.tarladan.modules.customer.entity.Customer;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CustomerRepository extends JpaRepository<Customer, Long> {
}
