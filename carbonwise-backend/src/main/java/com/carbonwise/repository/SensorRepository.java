package com.carbonwise.repository;

import com.carbonwise.entity.Sensor;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface SensorRepository extends JpaRepository<Sensor, String> {
    List<Sensor> findByCityId(String cityId);
    List<Sensor> findByIsActiveTrue();
}
