package com.carbonwise.controller;
import com.carbonwise.dto.DeviceDTO; import com.carbonwise.entity.Device;
import com.carbonwise.mapper.DeviceMapper; import com.carbonwise.repository.DeviceRepository;
import com.carbonwise.validation.DeviceValidation;
import lombok.RequiredArgsConstructor; import org.springframework.http.ResponseEntity; import org.springframework.web.bind.annotation.*;
import java.util.List; import java.util.stream.Collectors;

@RestController @RequestMapping("/api/device") @RequiredArgsConstructor
public class DeviceController {
    private final DeviceRepository deviceRepository; private final DeviceMapper deviceMapper; private final DeviceValidation deviceValidation;
    @PostMapping public ResponseEntity<DeviceDTO> addDevice(@RequestBody DeviceDTO request, @RequestParam String userId) {
        deviceValidation.validateDevice(request);
        Device device = Device.builder().userId(userId).name(request.getName()).type(request.getType()).powerRating(request.getPowerRating()).isActive(false).isScheduled(false).build();
        return ResponseEntity.ok(deviceMapper.toDTO(deviceRepository.save(device)));
    }
    @GetMapping public ResponseEntity<List<DeviceDTO>> getDevices(@RequestParam String userId) { return ResponseEntity.ok(deviceRepository.findByUserId(userId).stream().map(deviceMapper::toDTO).collect(Collectors.toList())); }
    @PutMapping("/{id}") public ResponseEntity<DeviceDTO> updateDevice(@PathVariable String id, @RequestBody DeviceDTO request) {
        Device device = deviceRepository.findById(id).orElse(null); if (device == null) return ResponseEntity.notFound().build();
        device.setName(request.getName()); device.setType(request.getType()); device.setPowerRating(request.getPowerRating()); device.setIsActive(request.getIsActive());
        return ResponseEntity.ok(deviceMapper.toDTO(deviceRepository.save(device)));
    }
    @DeleteMapping("/{id}") public ResponseEntity<Void> deleteDevice(@PathVariable String id) { deviceRepository.deleteById(id); return ResponseEntity.ok().build(); }
}
