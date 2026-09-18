package com.carbonwise.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "carbon_intensity")
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class CarbonIntensity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    @Column(nullable = false) private Double intensity;
    @Column(nullable = false) private Double solarWindPercent;
    @Column(nullable = false) private Double hydroPercent;
    @Column(nullable = false) private Double gasPercent;
    @Column(nullable = false) private Double coalPercent;
    private String region;
    @Column(nullable = false) private LocalDateTime timestamp;
    private String status;
}
