package com.carbonwise.repository;

import com.carbonwise.entity.SensorData;
import org.springframework.data.jpa.repository.JpaRepository;
import java.time.LocalDateTime;
import java.util.List;

public interface SensorDataRepository extends JpaRepository<SensorData, Long> {
    List<SensorData> findBySensorId(String sensorId);
    List<SensorData> findBySensorIdAndTimestampBetween(String sensorId, LocalDateTime start, LocalDateTime end);
    List<SensorData> findByTimestampAfter(LocalDateTime timestamp);
}
