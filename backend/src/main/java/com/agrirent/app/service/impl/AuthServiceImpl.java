package com.agrirent.app.service.impl;

import com.agrirent.app.dto.request.ForgotPasswordRequest;
import com.agrirent.app.dto.request.LoginRequest;
import com.agrirent.app.dto.request.RegisterRequest;
import com.agrirent.app.dto.request.UpdateProfileRequest;
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

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

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
    @Transactional
    public AuthResponse login(LoginRequest request) {
        String identifier = request.getUsernameOrEmail() != null ? request.getUsernameOrEmail().trim() : "";
        if (identifier.isEmpty()) {
            throw new BadRequestException("Email or mobile number is required.");
        }
        if (request.getPassword() == null || request.getPassword().isEmpty()) {
            throw new BadRequestException("Password is required.");
        }

        // Try exact match by email, username, or phone
        Optional<User> userOpt = userRepository.findByIdentifier(identifier);

        // If not found, try stripping non-digits if identifier might be a phone number
        if (userOpt.isEmpty()) {
            String digitsOnly = identifier.replaceAll("[^0-9]", "");
            if (digitsOnly.length() >= 10) {
                String local10 = digitsOnly.length() > 10 && digitsOnly.startsWith("91") 
                        ? digitsOnly.substring(2) 
                        : digitsOnly;
                userOpt = userRepository.findAll().stream()
                        .filter(u -> u.getPhone() != null && u.getPhone().replaceAll("[^0-9]", "").endsWith(local10))
                        .findFirst();
            }
        }

        User user = userOpt.orElseThrow(() -> new UnauthorizedException("Invalid email/mobile number or password."));

        boolean matches = passwordEncoder.matches(request.getPassword(), user.getPassword());
        if (!matches && request.getPassword().equals(user.getPassword())) {
            // Support plain password match for seed testing and auto-upgrade to BCrypt
            user.setPassword(passwordEncoder.encode(request.getPassword()));
            userRepository.save(user);
            matches = true;
        }

        if (!matches) {
            throw new UnauthorizedException("Invalid email/mobile number or password.");
        }

        user.setLastLoginAt(LocalDateTime.now());
        userRepository.save(user);

        UserDetails userDetails = userDetailsService.loadUserByUsername(user.getUsername());
        String token = jwtUtil.generateToken(userDetails, user.getRole());

        return new AuthResponse(token, userMapper.toResponse(user));
    }

    @Override
    @Transactional
    public AuthResponse register(RegisterRequest request) {
        // 1. First & Last Name Validation
        String firstName = request.getFirstName() != null ? request.getFirstName().trim() : "";
        String lastName = request.getLastName() != null ? request.getLastName().trim() : "";
        if (firstName.isEmpty()) {
            if (request.getFullName() != null && !request.getFullName().trim().isEmpty()) {
                String[] parts = request.getFullName().trim().split("\\s+", 2);
                firstName = parts[0];
                lastName = parts.length > 1 ? parts[1] : "";
            } else {
                throw new BadRequestException("First name is required.");
            }
        }

        // 2. Email Validation & Uniqueness
        if (request.getEmail() == null || !request.getEmail().trim().matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
            throw new BadRequestException("Please enter a valid email address.");
        }
        String cleanEmail = request.getEmail().trim().toLowerCase();
        if (userRepository.existsByEmail(cleanEmail)) {
            throw new BadRequestException("This email is already registered.");
        }

        // 3. Indian Mobile Number Validation & Uniqueness
        String rawPhone = request.getPhone() != null ? request.getPhone().trim() : "";
        String phoneDigits = rawPhone.replaceAll("[^0-9]", "");
        if (phoneDigits.length() > 10 && phoneDigits.startsWith("91")) {
            phoneDigits = phoneDigits.substring(2);
        }
        if (phoneDigits.length() != 10) {
            throw new BadRequestException("Please enter a valid 10-digit Indian mobile number.");
        }
        final String tenDigitPhone = phoneDigits;
        boolean phoneExists = userRepository.findAll().stream()
                .anyMatch(u -> u.getPhone() != null && u.getPhone().replaceAll("[^0-9]", "").endsWith(tenDigitPhone));
        if (phoneExists) {
            throw new BadRequestException("Mobile number is already registered.");
        }

        // 4. Password Validation
        if (request.getPassword() == null || request.getPassword().length() < 6) {
            throw new BadRequestException("Password must be at least 6 characters long.");
        }

        // 5. Role Validation (Farmer, Equipment Owner, Dealer - NEVER allow public Admin registration)
        String roleInput = request.getRole() != null ? request.getRole().trim().toUpperCase() : "";
        if (roleInput.contains("ADMIN")) {
            throw new BadRequestException("Admin registration is not permitted. Admin accounts must be created by system administrators.");
        }
        String role = "ROLE_FARMER";
        if (roleInput.contains("OWNER") || roleInput.equals("EQUIPMENT OWNER")) {
            role = "ROLE_OWNER";
        } else if (roleInput.contains("DEALER")) {
            role = "ROLE_DEALER";
        } else if (roleInput.contains("FARMER")) {
            role = "ROLE_FARMER";
        } else {
            throw new BadRequestException("Please select an account type.");
        }

        // 6. Username Generation
        String baseUsername = cleanEmail.split("@")[0].replaceAll("[^a-zA-Z0-9_]", "_");
        String username = baseUsername;
        if (userRepository.existsByUsername(username)) {
            username = baseUsername + "_" + (System.currentTimeMillis() % 10000);
        }

        // 7. Persist User Entity
        User user = new User();
        user.setUsername(username);
        user.setEmail(cleanEmail);
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setFirstName(firstName);
        user.setLastName(lastName);
        user.setFullName((firstName + " " + lastName).trim());
        user.setRole(role);
        user.setPhone("+91 " + phoneDigits.substring(0, 5) + " " + phoneDigits.substring(5));
        user.setFarmName(request.getFarmName() != null && !request.getFarmName().trim().isEmpty() 
                ? request.getFarmName().trim() 
                : (firstName + "'s Farm"));
        user.setAddress(request.getAddress());
        user.setDistrict(request.getDistrict() != null ? request.getDistrict() : "Pune");
        user.setCity(request.getCity() != null ? request.getCity() : (request.getDistrict() != null ? request.getDistrict() : "Pune"));
        user.setState("Maharashtra");
        user.setPincode(request.getPincode() != null ? request.getPincode() : "411001");
        user.setIsVerified(true);
        user.setIsActive(true);
        user.setLastLoginAt(LocalDateTime.now());

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

    @Override
    @Transactional
    public UserResponse updateProfile(UpdateProfileRequest request) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated() || auth.getPrincipal().equals("anonymousUser")) {
            throw new UnauthorizedException("User not authenticated");
        }

        String username = auth.getName();
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new UnauthorizedException("User not found: " + username));

        if (request.getFirstName() != null && !request.getFirstName().trim().isEmpty()) {
            user.setFirstName(request.getFirstName().trim());
        }
        if (request.getLastName() != null && !request.getLastName().trim().isEmpty()) {
            user.setLastName(request.getLastName().trim());
        }
        if (user.getFirstName() != null) {
            user.setFullName((user.getFirstName() + " " + (user.getLastName() != null ? user.getLastName() : "")).trim());
        }
        if (request.getPhone() != null && !request.getPhone().trim().isEmpty()) {
            user.setPhone(request.getPhone().trim());
        }
        if (request.getFarmName() != null) {
            user.setFarmName(request.getFarmName().trim());
        }
        if (request.getAddress() != null) {
            user.setAddress(request.getAddress().trim());
        }
        if (request.getDistrict() != null) {
            user.setDistrict(request.getDistrict().trim());
        }
        if (request.getCity() != null) {
            user.setCity(request.getCity().trim());
        }
        if (request.getState() != null) {
            user.setState(request.getState().trim());
        }
        if (request.getPincode() != null) {
            user.setPincode(request.getPincode().trim());
        }
        if (request.getAvatarUrl() != null) {
            user.setAvatarUrl(request.getAvatarUrl().trim());
        }

        User updated = userRepository.save(user);
        return userMapper.toResponse(updated);
    }

    @Override
    public Map<String, String> forgotPassword(ForgotPasswordRequest request) {
        String identifier = request.getEmailOrPhone() != null ? request.getEmailOrPhone().trim() : "";
        if (identifier.isEmpty()) {
            throw new BadRequestException("Email or mobile number is required.");
        }

        // Check if user exists
        Optional<User> userOpt = userRepository.findByIdentifier(identifier);
        if (userOpt.isEmpty()) {
            String digitsOnly = identifier.replaceAll("[^0-9]", "");
            if (digitsOnly.length() >= 10) {
                String local10 = digitsOnly.length() > 10 && digitsOnly.startsWith("91") ? digitsOnly.substring(2) : digitsOnly;
                userOpt = userRepository.findAll().stream()
                        .filter(u -> u.getPhone() != null && u.getPhone().replaceAll("[^0-9]", "").endsWith(local10))
                        .findFirst();
            }
        }

        Map<String, String> response = new HashMap<>();
        response.put("status", "SUCCESS");
        response.put("message", "Password reset instructions have been sent to your registered contact (" + identifier + "). In demo mode, you can log in directly using your existing credentials or register a new account.");
        return response;
    }
}
