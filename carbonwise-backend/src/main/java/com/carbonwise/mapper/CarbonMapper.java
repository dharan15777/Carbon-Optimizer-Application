package com.carbonwise.mapper;
import com.carbonwise.entity.CarbonIntensity;
import com.carbonwise.dto.CarbonDTO;
import org.springframework.stereotype.Component;

@Component
public class CarbonMapper {
    public CarbonDTO toDTO(CarbonIntensity entity) {
        if (entity == null) return null;
        return CarbonDTO.builder()
            .intensity(entity.getIntensity())
            .solarWindPercent(entity.getSolarWindPercent())
            .hydroPercent(entity.getHydroPercent())
            .gasPercent(entity.getGasPercent())
            .coalPercent(entity.getCoalPercent())
            .status(entity.getStatus())
            .timestamp(entity.getTimestamp().toString())
            .build();
    }
}
