package com.carbonwise.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "cities")
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class City {
    @Id @GeneratedValue(strategy = GenerationType.UUID) private String id;
    @Column(nullable = false) private String name;
    @Column(nullable = false) private String state;
    @Column(nullable = false) private Double latitude;
    @Column(nullable = false) private Double longitude;
    private Double radiusKm; private Boolean isActive = true; private LocalDateTime createdAt;
}
