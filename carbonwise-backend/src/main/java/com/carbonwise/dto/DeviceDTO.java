package com.carbonwise.dto;
import lombok.*;
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class DeviceDTO { private String id; private String userId; private String name; private String type; private Double powerRating; private Boolean isActive; private Boolean isScheduled; private String scheduleId; }
