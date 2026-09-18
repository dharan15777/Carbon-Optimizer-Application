package com.carbonwise.validation;
import com.carbonwise.dto.DeviceDTO;
import org.springframework.stereotype.Component;

@Component
public class DeviceValidation {
    public void validateDevice(DeviceDTO dto) {
        if (dto.getName() == null || dto.getName().isBlank()) throw new IllegalArgumentException("Device name is required");
        if (dto.getType() == null || dto.getType().isBlank()) throw new IllegalArgumentException("Device type is required");
        if (dto.getPowerRating() == null || dto.getPowerRating() <= 0) throw new IllegalArgumentException("Power rating must be positive");
    }
}
