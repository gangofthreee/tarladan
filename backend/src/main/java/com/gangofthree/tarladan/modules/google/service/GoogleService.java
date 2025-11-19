package com.gangofthree.tarladan.modules.google.service;

import com.gangofthree.tarladan.modules.google.dto.AuthStatusResponse;
import com.gangofthree.tarladan.modules.google.dto.GoogleAuthRequest;
import com.gangofthree.tarladan.modules.google.dto.GoogleRegisterRequest;
import com.gangofthree.tarladan.common.dto.TokenResponse;

public interface GoogleService {

    //Aşama 1: Sadece token'ı doğrular ve kullanıcının veritabanında var olup olmadığını kontrol eder.
    AuthStatusResponse verifyStatus(GoogleAuthRequest request);

    //Aşama 2: Yeni kullanıcıları role ve telefon bilgisiyle kaydeder, mevcut kullanıcıların girişini yapar.
    TokenResponse processAuth(GoogleRegisterRequest request);
}