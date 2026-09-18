package com.carbonwise.mapper;

import com.carbonwise.entity.User;
import com.carbonwise.dto.UserDTO;
import org.springframework.stereotype.Component;

@Component
public class UserMapper {

    public UserDTO toDTO(User entity) {
        if (entity == null) {
            return null;
        }
        return UserDTO.builder()
            .id(entity.getId())
            .name(entity.getName())
            .email(entity.getEmail())
            .role(entity.getRole())
            .phone(entity.getPhone())
            .city(entity.getCity())
            .profileImage(entity.getProfileImage())
            .isVerified(entity.getIsVerified())
            .createdAt(entity.getCreatedAt())
            .updatedAt(entity.getUpdatedAt())
            .build();
    }
}

