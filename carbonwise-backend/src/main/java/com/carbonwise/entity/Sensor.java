package com.carbonwise.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "sensors")
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class Sensor {
    @Id @GeneratedValue(strategy = GenerationType.UUID) private String id;
    @Column(nullable = false) private String cityId;
    @Column(nullable = false) private String name;
    @Column(nullable = false) private String type;
    @Column(nullable = false) private Double latitude;
    @Column(nullable = false) private Double longitude;
    private Boolean isActive = true; private String mqttTopic;
    private LocalDateTime lastReading; private LocalDateTime createdAt;
}
