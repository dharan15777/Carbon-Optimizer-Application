package com.carbonwise.ai;
import com.carbonwise.dto.PredictionDTO; import org.springframework.beans.factory.annotation.Value; import org.springframework.stereotype.Service; import org.springframework.web.client.RestTemplate;

@Service
public class AiServiceClient {
    @Value("${ai.server-url}") private String aiServerUrl;
    private final RestTemplate restTemplate = new RestTemplate();
    public PredictionDTO getPrediction(int hours) { return restTemplate.getForObject(aiServerUrl + "/api/prediction/" + hours + "h", PredictionDTO.class); }
    public Object getSpatialInterpolation(int gridResolution) { return restTemplate.postForObject(aiServerUrl + "/api/gis/interpolate", java.util.Map.of("grid_resolution", gridResolution), Object.class); }
}
