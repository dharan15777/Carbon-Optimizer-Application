package com.carbonwise.dto;
import lombok.*;
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class CarbonDTO { private Double intensity; private Double solarWindPercent; private Double hydroPercent; private Double gasPercent; private Double coalPercent; private String status; private String timestamp; }
