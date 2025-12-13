package com.gangofthree.tarladan.infrastructure.rateLimit;

import io.github.bucket4j.Bandwidth;
import io.github.bucket4j.Bucket;
import io.github.bucket4j.BucketConfiguration;
import io.github.bucket4j.Refill;
import io.github.bucket4j.distributed.proxy.ProxyManager;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.nio.charset.StandardCharsets; // BU IMPORT ÖNEMLİ
import java.time.Duration;
import java.util.function.Supplier;

@Service
public class RateLimitingService {

    // ARTIK <String> DEĞİL <byte[]> BEKLİYORUZ
    private final ProxyManager<byte[]> proxyManager;

    @Autowired
    public RateLimitingService(ProxyManager<byte[]> proxyManager) {
        this.proxyManager = proxyManager;
    }

    // --- TASK 1: KRİTİK GÜVENLİK ---
    public Bucket resolveLoginBucket(String key) {
        return proxyManager.builder().build(getBytes("login_" + key), config(5, Duration.ofMinutes(1)));
    }

    public Bucket resolveRegisterBucket(String key) {
        return proxyManager.builder().build(getBytes("register_" + key), config(3, Duration.ofMinutes(1)));
    }

    public Bucket resolvePwdResetBucket(String key) {
        return proxyManager.builder().build(getBytes("pwd_reset_" + key), config(3, Duration.ofHours(1)));
    }

    // --- TASK 2: MALİYET (SMS/EMAIL) ---
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

    // --- TASK 4: GENEL (SCRAPING KORUMASI) ---
    public Bucket resolveGeneralBucket(String key) {
        return proxyManager.builder().build(getBytes("general_" + key), config(60, Duration.ofMinutes(1)));
    }

    // --- YARDIMCI METOTLAR ---

    // String'i byte dizisine çeviren yardımcı metot
    private byte[] getBytes(String key) {
        return key.getBytes(StandardCharsets.UTF_8);
    }

    private Supplier<BucketConfiguration> config(long capacity, Duration period) {
        return () -> BucketConfiguration.builder()
                // DİKKAT: Burayı 'greedy' yerine 'intervally' yaptık.
                // Artık damla damla değil, süre dolunca toplu dolduracak.
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