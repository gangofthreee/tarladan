package com.gangofthree.tarladan.infrastructure.rateLimit;

import io.github.bucket4j.Bandwidth;
import io.github.bucket4j.Bucket;
import io.github.bucket4j.BucketConfiguration;
import io.github.bucket4j.Refill;
import io.github.bucket4j.distributed.proxy.ProxyManager;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.function.Supplier;

@Service
public class RateLimitingService {

    // Bucket keys are byte[] (required by the Lettuce-based ProxyManager), not String.
    private final ProxyManager<byte[]> proxyManager;

    @Autowired
    public RateLimitingService(ProxyManager<byte[]> proxyManager) {
        this.proxyManager = proxyManager;
    }

    // --- TASK 1: CRITICAL SECURITY ---
    public Bucket resolveLoginBucket(String key) {
        return proxyManager.builder().build(getBytes("login_" + key), config(5, Duration.ofMinutes(1)));
    }

    public Bucket resolveRegisterBucket(String key) {
        return proxyManager.builder().build(getBytes("register_" + key), config(3, Duration.ofMinutes(1)));
    }

    public Bucket resolvePwdResetBucket(String key) {
        return proxyManager.builder().build(getBytes("pwd_reset_" + key), config(3, Duration.ofHours(1)));
    }

    // --- TASK 2: COST CONTROL (SMS/EMAIL) ---
    public Bucket resolveResendCodeBucket(String key) {
        return proxyManager.builder().build(getBytes("resend_" + key), multiLimitConfig());
    }

    public Bucket resolveVerifyCodeBucket(String key) {
        return proxyManager.builder().build(getBytes("verify_" + key), config(5, Duration.ofMinutes(1)));
    }

    // --- TASK 3: RESOURCE HEAVY (UPLOAD/ORDER) ---
    public Bucket resolveUploadBucket(String key) {
        return proxyManager.builder().build(getBytes("upload_" + key), config(10, Duration.ofMinutes(1)));
    }

    public Bucket resolveOrderBucket(String key) {
        return proxyManager.builder().build(getBytes("order_" + key), config(10, Duration.ofMinutes(1)));
    }

    // --- TASK 4: GENERAL (SCRAPING PROTECTION) ---
    public Bucket resolveGeneralBucket(String key) {
        return proxyManager.builder().build(getBytes("general_" + key), config(60, Duration.ofMinutes(1)));
    }

    // --- HELPER METHODS ---

    // Converts a String key into a byte array.
    private byte[] getBytes(String key) {
        return key.getBytes(StandardCharsets.UTF_8);
    }

    private Supplier<BucketConfiguration> config(long capacity, Duration period) {
        return () -> BucketConfiguration.builder()
                // Uses 'intervally' refill: the full capacity is restored in one batch when
                // the period elapses, rather than trickling back in gradually ('greedy').
                .addLimit(Bandwidth.classic(capacity, Refill.intervally(capacity, period)))
                .build();
    }

    private Supplier<BucketConfiguration> multiLimitConfig() {
        return () -> BucketConfiguration.builder()
                .addLimit(Bandwidth.classic(1, Refill.greedy(1, Duration.ofMinutes(1))))
                .addLimit(Bandwidth.classic(5, Refill.greedy(5, Duration.ofHours(1))))
                .build();
    }
}