package com.carbonwise.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "ai_models")
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class AIModel {
    @Id @GeneratedValue(strategy = GenerationType.UUID) private String id;
    @Column(nullable = false) private String name;
    @Column(nullable = false) private String type;
    @Column(nullable = false) private String version;
    private Double accuracy; private String description;
    private String filePath; private Boolean isActive = true;
    private LocalDateTime createdAt; private LocalDateTime updatedAt;
}
