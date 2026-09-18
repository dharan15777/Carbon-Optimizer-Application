package com.carbonwise.dto;
import lombok.*;
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class DashboardDTO { private CarbonDTO liveCarbon; private Double totalCarbonSaved; private Double totalElectricityUsed; private Double renewablePercentage; private Integer activeDevices; private String bestChargingTime; private String bestApplianceTime; }
