package com.carbonwise.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "notifications")
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class Notification {
    @Id @GeneratedValue(strategy = GenerationType.UUID) private String id;
    @Column(nullable = false) private String userId;
    @Column(nullable = false) private String type;
    @Column(nullable = false) private String title;
    @Column(nullable = false) private String message;
    private Boolean isRead = false; private LocalDateTime createdAt;
}
