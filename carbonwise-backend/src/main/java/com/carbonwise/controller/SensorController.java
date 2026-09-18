package com.carbonwise.controller;
import com.carbonwise.dto.SensorDTO; import com.carbonwise.entity.SensorData;
import com.carbonwise.repository.SensorDataRepository; import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity; import org.springframework.web.bind.annotation.*;
import java.time.LocalDateTime; import java.util.List; import java.util.stream.Collectors;

@RestController @RequestMapping("/api/sensor") @RequiredArgsConstructor
public class SensorController {
    private final SensorDataRepository sensorDataRepository;
    @PostMapping("/data") public ResponseEntity<Void> postSensorData(@RequestBody SensorDTO request) {
        SensorData data = SensorData.builder().sensorId(request.getSensorId()).co2(request.getCo2()).pm25(request.getPm25()).pm10(request.getPm10()).temperature(request.getTemperature()).humidity(request.getHumidity()).timestamp(LocalDateTime.now()).build();
        sensorDataRepository.save(data); return ResponseEntity.ok().build();
    }
    @GetMapping("/live") public ResponseEntity<List<SensorDTO>> getLiveSensorData() {
        LocalDateTime cutoff = LocalDateTime.now().minusMinutes(30);
        return ResponseEntity.ok(sensorDataRepository.findByTimestampAfter(cutoff).stream().map(d -> SensorDTO.builder().sensorId(d.getSensorId()).co2(d.getCo2()).pm25(d.getPm25()).pm10(d.getPm10()).temperature(d.getTemperature()).humidity(d.getHumidity()).timestamp(d.getTimestamp().toString()).build()).collect(Collectors.toList()));
    }
}
