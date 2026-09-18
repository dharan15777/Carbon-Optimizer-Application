package com.carbonwise.repository;

import com.carbonwise.entity.Device;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface DeviceRepository extends JpaRepository<Device, String> {
    List<Device> findByUserId(String userId);
}
