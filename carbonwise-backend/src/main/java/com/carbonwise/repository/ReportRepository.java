package com.carbonwise.repository;

import com.carbonwise.entity.Report;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface ReportRepository extends JpaRepository<Report, String> {
    List<Report> findByUserId(String userId);
    Optional<Report> findByUserIdAndType(String userId, String type);
}
