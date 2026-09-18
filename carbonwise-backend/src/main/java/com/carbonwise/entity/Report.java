package com.carbonwise.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "reports")
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class Report {
    @Id @GeneratedValue(strategy = GenerationType.UUID) private String id;
    @Column(nullable = false) private String userId;
    @Column(nullable = false) private String type;
    @Column(nullable = false) private LocalDateTime startDate;
    @Column(nullable = false) private LocalDateTime endDate;
    @Column(nullable = false) private Double totalCarbonUsed;
    @Column(nullable = false) private Double totalCarbonSaved;
    @Column(nullable = false) private Double totalElectricityUsed;
    @Column(nullable = false) private Double renewablePercentage;
    private Integer deviceCount; private String pdfUrl; private LocalDateTime createdAt;
}
