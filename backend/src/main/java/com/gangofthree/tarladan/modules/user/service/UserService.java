package com.gangofthree.tarladan.modules.user.service;
import com.gangofthree.tarladan.modules.user.dto.UserLoginResponse;
import com.gangofthree.tarladan.modules.user.dto.UserRegisterRequest;
import com.gangofthree.tarladan.modules.user.entity.User;
import com.gangofthree.tarladan.modules.user.dto.UserLoginRequest;


public interface UserService {
    User register(UserRegisterRequest request);
    UserLoginResponse login(UserLoginRequest request);

}

