package com.carbonwise.repository;

import com.carbonwise.entity.CarbonIntensity;
import org.springframework.data.jpa.repository.JpaRepository;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface CarbonIntensityRepository extends JpaRepository<CarbonIntensity, Long> {
    Optional<CarbonIntensity> findTopByOrderByTimestampDesc();
    List<CarbonIntensity> findByTimestampBetween(LocalDateTime start, LocalDateTime end);
    List<CarbonIntensity> findByRegion(String region);
}
