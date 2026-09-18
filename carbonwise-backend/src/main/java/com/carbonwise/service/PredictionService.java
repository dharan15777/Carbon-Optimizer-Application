package com.carbonwise.service;
import com.carbonwise.dto.PredictionDTO; import org.springframework.beans.factory.annotation.Value; import org.springframework.stereotype.Service; import org.springframework.web.client.RestTemplate;

@Service
public class PredictionService {
    @Value("${ai.server-url}") private String aiServerUrl;
    private final RestTemplate restTemplate = new RestTemplate();
    public PredictionDTO getPrediction(int hours) {
        try { return restTemplate.getForObject(aiServerUrl + "/api/prediction/" + hours + "h", PredictionDTO.class); }
        catch (Exception e) { return PredictionDTO.builder().id("fallback").predictedAt(java.time.LocalDateTime.now().toString()).bestChargingTime("10:00 AM - 2:00 PM").bestApplianceTime("11:00 AM - 1:00 PM").recommendation("Schedule heavy loads during peak solar generation hours.").build(); }
    }
}
