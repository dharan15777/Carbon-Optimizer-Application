package com.carbonwise.dto;
import lombok.*;
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class SensorDTO { private String sensorId; private Double co2; private Double pm25; private Double pm10; private Double temperature; private Double humidity; private String timestamp; }
