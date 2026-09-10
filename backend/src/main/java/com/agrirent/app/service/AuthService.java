package com.agrirent.app.service;

import com.agrirent.app.dto.request.LoginRequest;
import com.agrirent.app.dto.request.RegisterRequest;
import com.agrirent.app.dto.response.AuthResponse;
import com.agrirent.app.dto.response.UserResponse;

public interface AuthService {
    AuthResponse login(LoginRequest request);
    AuthResponse register(RegisterRequest request);
    UserResponse getCurrentUser();
}
