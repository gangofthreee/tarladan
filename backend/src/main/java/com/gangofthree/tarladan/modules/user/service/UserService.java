package com.gangofthree.tarladan.modules.user.service;
import com.gangofthree.tarladan.modules.user.dto.UserRegisterRequest;
import com.gangofthree.tarladan.modules.user.entity.User;

public interface UserService {
    User register(UserRegisterRequest request);
}

