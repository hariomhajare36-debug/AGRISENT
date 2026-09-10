package com.agrirent.app.mapper;

import com.agrirent.app.dto.response.UserResponse;
import com.agrirent.app.entity.User;
import org.springframework.stereotype.Component;

@Component
public class UserMapper {

    public UserResponse toResponse(User user) {
        if (user == null) return null;
        UserResponse response = new UserResponse();
        response.setId(user.getId());
        response.setUsername(user.getUsername());
        response.setEmail(user.getEmail());
        response.setFullName(user.getFullName());
        response.setRole(user.getRole());
        response.setFarmName(user.getFarmName());
        response.setPhone(user.getPhone());
        response.setCity(user.getCity());
        response.setState(user.getState());
        response.setIsVerified(user.getIsVerified());
        response.setFirstName(user.getFirstName());
        response.setLastName(user.getLastName());
        response.setDistrict(user.getDistrict());
        response.setAddress(user.getAddress());
        response.setPincode(user.getPincode());
        response.setAvatarUrl(user.getAvatarUrl());
        return response;
    }
}
