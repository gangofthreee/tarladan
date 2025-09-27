package com.gangofthree.tarladan.service;
import com.gangofthree.tarladan.dto.UserRegisterRequest;
import com.gangofthree.tarladan.entity.User;

public interface UserService {
    User register(UserRegisterRequest request);
}

