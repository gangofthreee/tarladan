package com.gangofthree.tarladan.service;

import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.util.concurrent.TimeUnit;

@Service
@RequiredArgsConstructor
public class RedisService {

    private final StringRedisTemplate redisTemplate;

    public void saveVerificationCode(String email, String code) {
        redisTemplate.opsForValue().set(email, code, 2, TimeUnit.MINUTES);
    }

    public String getVerificationCode(String email) {
        return redisTemplate.opsForValue().get(email);
    }

    public void deleteCode(String email) {
        redisTemplate.delete(email);
    }
}

