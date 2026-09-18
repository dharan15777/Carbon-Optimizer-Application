package com.carbonwise.controller;
import com.carbonwise.dto.ScheduleDTO; import com.carbonwise.entity.Schedule;
import com.carbonwise.repository.ScheduleRepository; import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity; import org.springframework.web.bind.annotation.*;
import java.time.LocalDateTime; import java.util.List; import java.util.stream.Collectors;

@RestController @RequestMapping("/api/schedule") @RequiredArgsConstructor
public class ScheduleController {
    private final ScheduleRepository scheduleRepository;
    @PostMapping public ResponseEntity<ScheduleDTO> createSchedule(@RequestBody ScheduleDTO request) {
        Schedule schedule = Schedule.builder().deviceId(request.getDeviceId()).userId(request.getUserId()).startTime(LocalDateTime.parse(request.getStartTime())).endTime(LocalDateTime.parse(request.getEndTime())).isAiRecommended(request.getIsAiRecommended()).estimatedCarbonSaving(request.getEstimatedCarbonSaving()).status("PENDING").createdAt(LocalDateTime.now()).build();
        Schedule saved = scheduleRepository.save(schedule);
        return ResponseEntity.ok(ScheduleDTO.builder().id(saved.getId()).deviceId(saved.getDeviceId()).userId(saved.getUserId()).startTime(saved.getStartTime().toString()).endTime(saved.getEndTime().toString()).isAiRecommended(saved.getIsAiRecommended()).estimatedCarbonSaving(saved.getEstimatedCarbonSaving()).status(saved.getStatus()).build());
    }
    @GetMapping public ResponseEntity<List<ScheduleDTO>> getSchedules(@RequestParam String userId) {
        return ResponseEntity.ok(scheduleRepository.findByUserId(userId).stream().map(s -> ScheduleDTO.builder().id(s.getId()).deviceId(s.getDeviceId()).userId(s.getUserId()).startTime(s.getStartTime().toString()).endTime(s.getEndTime().toString()).isAiRecommended(s.getIsAiRecommended()).estimatedCarbonSaving(s.getEstimatedCarbonSaving()).status(s.getStatus()).build()).collect(Collectors.toList()));
    }
}
