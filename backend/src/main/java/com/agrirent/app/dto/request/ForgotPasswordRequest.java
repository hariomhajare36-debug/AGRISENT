package com.agrirent.app.dto.request;

import jakarta.validation.constraints.NotBlank;

public class ForgotPasswordRequest {
    @NotBlank(message = "Email or mobile number is required")
    private String emailOrPhone;

    public ForgotPasswordRequest() {}

    public String getEmailOrPhone() { return emailOrPhone; }
    public void setEmailOrPhone(String emailOrPhone) { this.emailOrPhone = emailOrPhone; }
}
