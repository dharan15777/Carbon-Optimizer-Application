package com.carbonwise.service;

import com.carbonwise.dto.AuthDTO;
import com.carbonwise.dto.UserDTO;
import com.carbonwise.entity.User;
import com.carbonwise.exception.ResourceNotFoundException;
import com.carbonwise.exception.UnauthorizedException;
import com.carbonwise.exception.UserAlreadyExistsException;
import com.carbonwise.mapper.UserMapper;
import com.carbonwise.repository.UserRepository;
import com.carbonwise.security.JwtUtil;
import com.carbonwise.validation.AuthValidation;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final UserMapper userMapper;
    private final AuthValidation authValidation;

    public AuthDTO.AuthResponse login(AuthDTO.LoginRequest request) {
        authValidation.validateLogin(request);
        User user = userRepository.findByEmail(request.getEmail().trim().toLowerCase())
            .orElseThrow(() -> new UnauthorizedException("Invalid email or password."));

        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new UnauthorizedException("Invalid email or password.");
        }

        String token = jwtUtil.generateToken(user.getId(), user.getRole());
        String refreshToken = jwtUtil.generateRefreshToken(user.getId());

        return AuthDTO.AuthResponse.builder()
            .token(token)
            .refreshToken(refreshToken)
            .userId(user.getId())
            .role(user.getRole())
            .user(userMapper.toDTO(user))
            .build();
    }

    public AuthDTO.AuthResponse register(AuthDTO.RegisterRequest request) {
        authValidation.validateRegister(request);
        String normalizedEmail = request.getEmail().trim().toLowerCase();

        if (userRepository.existsByEmail(normalizedEmail)) {
            throw new UserAlreadyExistsException("An account with this email already exists. Please login.");
        }

        User user = User.builder()
            .name(request.getName().trim())
            .email(normalizedEmail)
            .password(passwordEncoder.encode(request.getPassword()))
            .role(request.getRole() != null ? request.getRole() : "CONSUMER")
            .isVerified(false)
            .createdAt(LocalDateTime.now())
            .build();

        User saved = userRepository.save(user);

        String token = jwtUtil.generateToken(saved.getId(), saved.getRole());
        String refreshToken = jwtUtil.generateRefreshToken(saved.getId());

        return AuthDTO.AuthResponse.builder()
            .token(token)
            .refreshToken(refreshToken)
            .userId(saved.getId())
            .role(saved.getRole())
            .user(userMapper.toDTO(saved))
            .build();
    }

    public boolean verifyOTP(String email, String otp) {
        User user = userRepository.findByEmail(email.trim().toLowerCase())
            .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        user.setIsVerified(true);
        user.setUpdatedAt(LocalDateTime.now());
        userRepository.save(user);
        return true;
    }

    public void forgotPassword(String email) {
        // Find user to verify existence; password reset email can be sent asynchronously
        userRepository.findByEmail(email.trim().toLowerCase());
    }

    public AuthDTO.AuthResponse refreshToken(String refreshToken) {
        String userId = jwtUtil.extractUserId(refreshToken);
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new UnauthorizedException("Invalid refresh token."));

        return AuthDTO.AuthResponse.builder()
            .token(jwtUtil.generateToken(user.getId(), user.getRole()))
            .refreshToken(refreshToken)
            .userId(user.getId())
            .role(user.getRole())
            .user(userMapper.toDTO(user))
            .build();
    }
}

