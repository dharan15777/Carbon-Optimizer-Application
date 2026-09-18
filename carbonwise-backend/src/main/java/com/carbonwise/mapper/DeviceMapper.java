package com.carbonwise.mapper;
import com.carbonwise.entity.Device;
import com.carbonwise.dto.DeviceDTO;
import org.springframework.stereotype.Component;

@Component
public class DeviceMapper {
    public DeviceDTO toDTO(Device entity) {
        return DeviceDTO.builder()
            .id(entity.getId()).userId(entity.getUserId()).name(entity.getName())
            .type(entity.getType()).powerRating(entity.getPowerRating())
            .isActive(entity.getIsActive()).isScheduled(entity.getIsScheduled())
            .scheduleId(entity.getScheduleId()).build();
    }
}
