package com.carbonwise.repository;

import com.carbonwise.entity.Schedule;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ScheduleRepository extends JpaRepository<Schedule, String> {
    List<Schedule> findByUserId(String userId);
    List<Schedule> findByDeviceId(String deviceId);
}
