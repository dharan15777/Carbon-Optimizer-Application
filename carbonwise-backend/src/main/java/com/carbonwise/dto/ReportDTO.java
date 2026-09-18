package com.carbonwise.dto;
import lombok.*; import java.util.List;
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class ReportDTO { private String id; private String userId; private String type; private String startDate; private String endDate; private Double totalCarbonUsed; private Double totalCarbonSaved; private Double totalElectricityUsed; private Double renewablePercentage; private Integer deviceCount; private List<DeviceStatistic> deviceStatistics; private String pdfUrl;
    @Data @NoArgsConstructor @AllArgsConstructor public static class DeviceStatistic { private String deviceName; private String deviceType; private Double carbonUsed; private Double carbonSaved; private Double electricityUsed; }
}
