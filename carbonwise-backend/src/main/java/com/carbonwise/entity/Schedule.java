package com.carbonwise.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "schedules")
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class Schedule {
    @Id @GeneratedValue(strategy = GenerationType.UUID) private String id;
    @Column(nullable = false) private String deviceId;
    @Column(nullable = false) private String userId;
    @Column(nullable = false) private LocalDateTime startTime;
    @Column(nullable = false) private LocalDateTime endTime;
    @Column(nullable = false) private Boolean isAiRecommended = false;
    private Double estimatedCarbonSaving;
    @Column(nullable = false) private String status;
    private LocalDateTime createdAt; private LocalDateTime updatedAt;
}
