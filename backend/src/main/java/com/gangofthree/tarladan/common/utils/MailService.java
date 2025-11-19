package com.gangofthree.tarladan.common.utils;

import lombok.RequiredArgsConstructor;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class MailService {

    private final JavaMailSender mailSender;

    public void sendVerificationCode(String to, String code) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(to);
        message.setSubject("Tarladan - Email Doğrulama Kodu");
        message.setText("Merhaba,\n\nDoğrulama kodunuz: " + code + "\n\nKod 2 dakika geçerlidir.");
        mailSender.send(message);
    }

    public void sendResetCode(String to, String code) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(to);
        message.setSubject("Tarladan - Password Reset Code");
        message.setText("Şifre sıfırlama kodunuz: " + code + "\nKod 3 dakika geçerlidir.");
        mailSender.send(message);
    }

}

