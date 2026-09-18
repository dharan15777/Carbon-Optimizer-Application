package com.carbonwise.controller;
import com.carbonwise.dto.CarbonDTO; import com.carbonwise.dto.DashboardDTO;
import com.carbonwise.entity.CarbonIntensity;
import com.carbonwise.mapper.CarbonMapper;
import com.carbonwise.repository.CarbonIntensityRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDateTime; import java.util.List; import java.util.stream.Collectors;

@RestController @RequestMapping("/api/consumer") @RequiredArgsConstructor
public class ConsumerController {
    private final CarbonIntensityRepository carbonIntensityRepository; private final CarbonMapper carbonMapper;
    @GetMapping("/dashboard") public ResponseEntity<DashboardDTO> getDashboard(@RequestParam String userId) {
        CarbonIntensity latest = carbonIntensityRepository.findTopByOrderByTimestampDesc().orElse(null);
        DashboardDTO dashboard = DashboardDTO.builder().liveCarbon(carbonMapper.toDTO(latest)).totalCarbonSaved(86.1).totalElectricityUsed(350.0).renewablePercentage(57.0).activeDevices(4).bestChargingTime("10:00 AM - 2:00 PM").bestApplianceTime("11:00 AM - 1:00 PM").build();
        return ResponseEntity.ok(dashboard);
    }
    @GetMapping("/carbon/live") public ResponseEntity<CarbonDTO> getLiveCarbon() { return ResponseEntity.ok(carbonMapper.toDTO(carbonIntensityRepository.findTopByOrderByTimestampDesc().orElse(null))); }
    @GetMapping("/carbon/history") public ResponseEntity<List<CarbonDTO>> getCarbonHistory(@RequestParam(defaultValue = "30") int days) {
        LocalDateTime start = LocalDateTime.now().minusDays(days);
        return ResponseEntity.ok(carbonIntensityRepository.findByTimestampBetween(start, LocalDateTime.now()).stream().map(carbonMapper::toDTO).collect(Collectors.toList()));
    }
}
