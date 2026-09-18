package com.carbonwise.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "sensor_data")
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class SensorData {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    @Column(nullable = false) private String sensorId;
    @Column(nullable = false) private Double co2;
    @Column(nullable = false) private Double pm25;
    @Column(nullable = false) private Double pm10;
    @Column(nullable = false) private Double temperature;
    @Column(nullable = false) private Double humidity;
    @Column(nullable = false) private LocalDateTime timestamp;
}
