package com.carbonwise.scheduler;
import com.carbonwise.repository.ScheduleRepository; import lombok.RequiredArgsConstructor; import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled; import org.springframework.stereotype.Component;
import java.time.LocalDateTime; import java.util.List;

@Slf4j @Component @RequiredArgsConstructor
public class ScheduleChecker {
    private final ScheduleRepository scheduleRepository;
    @Scheduled(fixedRate = 60000) public void checkPendingSchedules() { List<com.carbonwise.entity.Schedule> pending = scheduleRepository.findByUserId("ALL"); log.info("Checking schedules at {}", LocalDateTime.now()); }
    @Scheduled(fixedRate = 300000) public void fetchLiveCarbonIntensity() { log.info("Fetching live carbon intensity data at {}", LocalDateTime.now()); }
}
