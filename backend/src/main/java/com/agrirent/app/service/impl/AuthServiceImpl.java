package com.agrirent.app.service.impl;

import com.agrirent.app.dto.request.LoginRequest;
import com.agrirent.app.dto.request.RegisterRequest;
import com.agrirent.app.dto.response.AuthResponse;
import com.agrirent.app.dto.response.UserResponse;
import com.agrirent.app.entity.User;
import com.agrirent.app.exception.BadRequestException;
import com.agrirent.app.exception.UnauthorizedException;
import com.agrirent.app.mapper.UserMapper;
import com.agrirent.app.repository.UserRepository;
import com.agrirent.app.security.CustomUserDetailsService;
import com.agrirent.app.security.JwtUtil;
import com.agrirent.app.service.AuthService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthServiceImpl implements AuthService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private CustomUserDetailsService userDetailsService;

    @Autowired
    private UserMapper userMapper;

    @Override
    public AuthResponse login(LoginRequest request) {
        User user = userRepository.findByUsernameOrEmail(request.getUsernameOrEmail(), request.getUsernameOrEmail())
                .orElseThrow(() -> new UnauthorizedException("Invalid username or password"));

        boolean matches = passwordEncoder.matches(request.getPassword(), user.getPassword());
        if (!matches && request.getPassword().equals(user.getPassword())) {
            // Support plain password match for seed testing and auto-upgrade to BCrypt
            user.setPassword(passwordEncoder.encode(request.getPassword()));
            userRepository.save(user);
            matches = true;
        }

        if (!matches) {
            throw new UnauthorizedException("Invalid username or password");
        }

        UserDetails userDetails = userDetailsService.loadUserByUsername(user.getUsername());
        String token = jwtUtil.generateToken(userDetails, user.getRole());

        return new AuthResponse(token, userMapper.toResponse(user));
    }

    @Override
    @Transactional
    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new BadRequestException("Email already in use: " + request.getEmail());
        }

        String username = request.getUsername();
        if (username == null || username.trim().isEmpty()) {
            username = request.getEmail().split("@")[0];
        }

        if (userRepository.existsByUsername(username)) {
            username = username + "_" + System.currentTimeMillis() % 10000;
        }

        User user = new User();
        user.setUsername(username);
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setFullName(request.getFullName());

        String role = request.getRole();
        if (role == null || (!role.equals("ROLE_OWNER") && !role.equals("ROLE_ADMIN"))) {
            role = "ROLE_FARMER";
        }
        user.setRole(role);
        user.setFarmName(request.getFarmName());
        user.setPhone(request.getPhone());
        user.setAddress(request.getAddress());
        user.setCity(request.getCity());
        user.setState(request.getState());
        user.setZipCode(request.getZipCode());
        user.setIsVerified(true);

        User savedUser = userRepository.save(user);

        UserDetails userDetails = userDetailsService.loadUserByUsername(savedUser.getUsername());
        String token = jwtUtil.generateToken(userDetails, savedUser.getRole());

        return new AuthResponse(token, userMapper.toResponse(savedUser));
    }

    @Override
    public UserResponse getCurrentUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated() || auth.getPrincipal().equals("anonymousUser")) {
            throw new UnauthorizedException("User not authenticated");
        }

        String username = auth.getName();
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new UnauthorizedException("User not found: " + username));

        return userMapper.toResponse(user);
    }
}
