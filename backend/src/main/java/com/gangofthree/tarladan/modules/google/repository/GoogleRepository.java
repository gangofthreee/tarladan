package com.gangofthree.tarladan.modules.google.repository;

import com.gangofthree.tarladan.modules.user.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface GoogleRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
}
