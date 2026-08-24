package com.gangofthree.tarladan.modules.google.service;

import com.gangofthree.tarladan.modules.google.dto.AuthStatusResponse;
import com.gangofthree.tarladan.modules.google.dto.GoogleAuthRequest;
import com.gangofthree.tarladan.modules.google.dto.GoogleRegisterRequest;
import com.gangofthree.tarladan.shared.dto.TokenResponse;

public interface GoogleService {

    // Step 1: Verifies the Google ID token and checks whether the user already exists in the database.
    AuthStatusResponse verifyStatus(GoogleAuthRequest request);

    // Step 2: Registers new users with their role and phone number, logs in existing users.
    TokenResponse processAuth(GoogleRegisterRequest request);
}