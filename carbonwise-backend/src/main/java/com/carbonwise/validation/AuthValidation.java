package com.carbonwise.validation;
import com.carbonwise.dto.AuthDTO;
import org.springframework.stereotype.Component;

@Component
public class AuthValidation {
    public void validateLogin(AuthDTO.LoginRequest request) {
        if (request.getEmail() == null || request.getEmail().isBlank()) throw new IllegalArgumentException("Email is required");
        if (request.getPassword() == null || request.getPassword().isBlank()) throw new IllegalArgumentException("Password is required");
    }
    public void validateRegister(AuthDTO.RegisterRequest request) {
        if (request.getName() == null || request.getName().isBlank()) throw new IllegalArgumentException("Name is required");
        if (request.getEmail() == null || request.getEmail().isBlank()) throw new IllegalArgumentException("Email is required");
        if (request.getPassword() == null || request.getPassword().length() < 6) throw new IllegalArgumentException("Password must be at least 6 characters");
        if (request.getRole() == null) throw new IllegalArgumentException("Role is required");
    }
}
