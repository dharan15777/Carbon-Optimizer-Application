package com.carbonwise.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/gis")
@RequiredArgsConstructor
public class GisController {

    @GetMapping("/heatmap/carbon")
    public ResponseEntity<List<Map<String, Object>>> getCarbonHeatmap() {
        List<Map<String, Object>> heatmap = List.of(
            Map.of("lat", 13.0827, "lng", 80.2707, "intensity", 118.0, "radius", 1200, "label", "Chennai Central Clean Hub"),
            Map.of("lat", 13.0500, "lng", 80.2500, "intensity", 142.0, "radius", 1400, "label", "T. Nagar Commercial Hub"),
            Map.of("lat", 13.0850, "lng", 80.2100, "intensity", 260.0, "radius", 1500, "label", "Anna Nagar Moderate Zone"),
            Map.of("lat", 13.0100, "lng", 80.2200, "intensity", 380.0, "radius", 1800, "label", "Guindy Industrial High Load"),
            Map.of("lat", 12.9800, "lng", 80.2500, "intensity", 95.0, "radius", 1300, "label", "Adyar Green Solar Cluster"),
            Map.of("lat", 13.1200, "lng", 80.2900, "intensity", 410.0, "radius", 2000, "label", "North Port Heavy Emissions")
        );
        return ResponseEntity.ok(heatmap);
    }

    @GetMapping("/sensors")
    public ResponseEntity<List<Map<String, Object>>> getSensors() {
        List<Map<String, Object>> sensors = List.of(
            Map.of("id", "S-101", "name", "Sensor Hub North", "lat", 13.0900, "lng", 80.2800, "co2", 412, "pm25", 28, "temp", 29.5, "status", "ONLINE", "type", "AIR_QUALITY"),
            Map.of("id", "S-102", "name", "Home Gateway #1", "lat", 13.0827, "lng", 80.2707, "co2", 385, "pm25", 18, "temp", 26.2, "status", "ONLINE", "type", "HOME_SMART_METER"),
            Map.of("id", "S-103", "name", "Substation Sensor #4", "lat", 13.0500, "lng", 80.2500, "co2", 460, "pm25", 38, "temp", 31.0, "status", "ONLINE", "type", "GRID_MONITOR"),
            Map.of("id", "S-104", "name", "Solar Farm Collector", "lat", 12.9800, "lng", 80.2500, "co2", 320, "pm25", 12, "temp", 28.0, "status", "ONLINE", "type", "RENEWABLE_FEED"),
            Map.of("id", "S-105", "name", "Industrial Park Node", "lat", 13.0100, "lng", 80.2200, "co2", 590, "pm25", 65, "temp", 33.2, "status", "WARNING", "type", "INDUSTRIAL")
        );
        return ResponseEntity.ok(sensors);
    }

    @GetMapping("/risk-zones")
    public ResponseEntity<List<Map<String, Object>>> getRiskZones() {
        List<Map<String, Object>> riskZones = List.of(
            Map.of("id", "RZ-1", "name", "Guindy Thermal Corridor", "lat", 13.0100, "lng", 80.2200, "radius", 2200, "riskLevel", "HIGH", "reason", "Heavy peak load and high grid carbon intensity (>400 gCO₂/kWh)"),
            Map.of("id", "RZ-2", "name", "Ennore Industrial Cluster", "lat", 13.1200, "lng", 80.2900, "radius", 2800, "riskLevel", "CRITICAL", "reason", "Coal thermal feed congestion")
        );
        return ResponseEntity.ok(riskZones);
    }
}
