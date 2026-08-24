package com.gangofthree.tarladan.interceptor;

import com.gangofthree.tarladan.infrastructure.rateLimit.RateLimitingService;
import io.github.bucket4j.Bucket;
import io.github.bucket4j.ConsumptionProbe;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

@Component
@RequiredArgsConstructor
public class RateLimitInterceptor implements HandlerInterceptor {

    private final RateLimitingService rateLimitingService;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {

        String clientIp = getClientIp(request);
        String uri = request.getRequestURI();
        String method = request.getMethod();

        Bucket tokenBucket;

        // TASK 1: CRITICAL SECURITY
        if (uri.equals("/api/users/login")) {
            tokenBucket = rateLimitingService.resolveLoginBucket(clientIp);
        }
        else if (uri.equals("/api/users/register")) {
            tokenBucket = rateLimitingService.resolveRegisterBucket(clientIp);
        }
        else if (uri.equals("/auth/password-reset")) {
            tokenBucket = rateLimitingService.resolvePwdResetBucket(clientIp);
        }
        // TASK 2: COST CONTROL
        else if (uri.equals("/api/verification/resendCode")) {
            tokenBucket = rateLimitingService.resolveResendCodeBucket(clientIp);
        }
        else if (uri.contains("/verification/verifyCode") || uri.contains("/confirm-code")) {
            tokenBucket = rateLimitingService.resolveVerifyCodeBucket(clientIp);
        }
        // TASK 3: RESOURCE HEAVY
        else if (uri.equals("/api/orders/create")) {
            tokenBucket = rateLimitingService.resolveOrderBucket(clientIp);
        }
        else if ((uri.contains("/truck/") || uri.contains("/farmer/product/")) &&
                (uri.contains("create") || uri.contains("update")) &&
                (method.equals("POST") || method.equals("PATCH"))) {
            tokenBucket = rateLimitingService.resolveUploadBucket(clientIp);
        }
        // TASK 4: GENERAL
        else {
            tokenBucket = rateLimitingService.resolveGeneralBucket(clientIp);
        }

        // Consume a token.
        ConsumptionProbe probe = tokenBucket.tryConsumeAndReturnRemaining(1);

        if (probe.isConsumed()) {
            response.addHeader("X-Rate-Limit-Remaining", String.valueOf(probe.getRemainingTokens()));
            return true;
        } else {
            long waitForRefill = probe.getNanosToWaitForRefill() / 1_000_000_000;

            response.setStatus(HttpStatus.TOO_MANY_REQUESTS.value());
            response.addHeader("X-Rate-Limit-Retry-After-Seconds", String.valueOf(waitForRefill));
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");

            String jsonResponse = String.format(
                    "{\"error\": \"Too Many Requests\", \"message\": \"Çok fazla işlem yaptınız.\", \"retryAfterSeconds\": %d}",
                    waitForRefill
            );
            response.getWriter().write(jsonResponse);

            return false;
        }
    }

    private String getClientIp(HttpServletRequest request) {
        String xfHeader = request.getHeader("X-Forwarded-For");
        if (xfHeader == null) {
            return request.getRemoteAddr();
        }
        // X-Forwarded-For is a comma-separated "client, proxy1, proxy2, ..." chain;
        // trim so a leading space on non-first entries doesn't fragment the rate-limit key.
        return xfHeader.split(",")[0].trim();
    }
}