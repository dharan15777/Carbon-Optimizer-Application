package com.carbonwise.controller;
import com.carbonwise.dto.ReportDTO; import com.carbonwise.service.ReportService;
import lombok.RequiredArgsConstructor; import org.springframework.http.ResponseEntity; import org.springframework.web.bind.annotation.*;

@RestController @RequestMapping("/api/reports") @RequiredArgsConstructor
public class ReportController {
    private final ReportService reportService;
    @GetMapping("/daily") public ResponseEntity<ReportDTO> getDaily(@RequestParam String userId) { return ResponseEntity.ok(reportService.getDailyReport(userId)); }
    @GetMapping("/weekly") public ResponseEntity<ReportDTO> getWeekly(@RequestParam String userId) { return ResponseEntity.ok(reportService.getWeeklyReport(userId)); }
    @GetMapping("/monthly") public ResponseEntity<ReportDTO> getMonthly(@RequestParam String userId) { return ResponseEntity.ok(reportService.getMonthlyReport(userId)); }
}
