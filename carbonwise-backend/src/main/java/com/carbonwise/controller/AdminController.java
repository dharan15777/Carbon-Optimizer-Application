package com.carbonwise.controller;
import com.carbonwise.entity.*; import com.carbonwise.repository.*;
import lombok.RequiredArgsConstructor; import org.springframework.http.ResponseEntity; import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController @RequestMapping("/api/admin") @RequiredArgsConstructor
public class AdminController {
    private final UserRepository userRepository; private final CityRepository cityRepository; private final SensorRepository sensorRepository;
    @GetMapping("/users") public ResponseEntity<List<User>> getUsers() { return ResponseEntity.ok(userRepository.findAll()); }
    @GetMapping("/cities") public ResponseEntity<List<City>> getCities() { return ResponseEntity.ok(cityRepository.findAll()); }
    @GetMapping("/sensors") public ResponseEntity<List<Sensor>> getSensors() { return ResponseEntity.ok(sensorRepository.findAll()); }
}
