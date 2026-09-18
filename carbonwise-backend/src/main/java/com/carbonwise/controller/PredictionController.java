package com.carbonwise.controller;
import com.carbonwise.dto.PredictionDTO; import com.carbonwise.service.PredictionService;
import lombok.RequiredArgsConstructor; import org.springframework.http.ResponseEntity; import org.springframework.web.bind.annotation.*;

@RestController @RequestMapping("/api/prediction") @RequiredArgsConstructor
public class PredictionController {
    private final PredictionService predictionService;
    @GetMapping("/6h") public ResponseEntity<PredictionDTO> get6h() { return ResponseEntity.ok(predictionService.getPrediction(6)); }
    @GetMapping("/12h") public ResponseEntity<PredictionDTO> get12h() { return ResponseEntity.ok(predictionService.getPrediction(12)); }
    @GetMapping("/24h") public ResponseEntity<PredictionDTO> get24h() { return ResponseEntity.ok(predictionService.getPrediction(24)); }
}
