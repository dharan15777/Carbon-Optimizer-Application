package com.carbonwise.dto;
import lombok.*; import java.util.List;
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class PredictionDTO { private String id; private String predictedAt; private List<DataPoint> dataPoints; private String bestChargingTime; private String bestApplianceTime; private String recommendation;
    @Data @NoArgsConstructor @AllArgsConstructor public static class DataPoint { private String time; private Double predictedIntensity; private Double confidence; }
}
