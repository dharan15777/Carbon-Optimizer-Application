package com.carbonwise.dto;
import lombok.*;
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class ScheduleDTO { private String id; private String deviceId; private String userId; private String startTime; private String endTime; private Boolean isAiRecommended; private Double estimatedCarbonSaving; private String status; }
