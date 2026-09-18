package com.carbonwise.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final List<Map<String, Object>> mockNotifications = new ArrayList<>(List.of(
        Map.of(
            "id", "notif-1",
            "userId", "user-1",
            "title", "Optimal Green Charging Active",
            "message", "Grid carbon intensity is currently low (118 gCO₂/kWh). Excellent time to charge EV.",
            "type", "GRID_CLEAN",
            "isRead", false,
            "createdAt", LocalDateTime.now().minusMinutes(25).toString()
        ),
        Map.of(
            "id", "notif-2",
            "userId", "user-1",
            "title", "AI Scheduled Smart Cycle",
            "message", "Smart Washing Machine scheduled for 1:30 PM today during peak renewable window.",
            "type", "BEST_CHARGING",
            "isRead", false,
            "createdAt", LocalDateTime.now().minusHours(2).toString()
        ),
        Map.of(
            "id", "notif-3",
            "userId", "user-1",
            "title", "Air Quality Normal",
            "message", "All localized IoT environmental sensors are online and within clean thresholds.",
            "type", "DEVICE_COMPLETED",
            "isRead", true,
            "createdAt", LocalDateTime.now().minusHours(5).toString()
        ),
        Map.of(
            "id", "notif-4",
            "userId", "user-1",
            "title", "Daily Carbon Savings Report Ready",
            "message", "You reduced your carbon footprint by 30% yesterday. View your full report now.",
            "type", "DAILY_REPORT",
            "isRead", true,
            "createdAt", LocalDateTime.now().minusDays(1).toString()
        )
    ));

    @GetMapping
    public ResponseEntity<List<Map<String, Object>>> getNotifications() {
        return ResponseEntity.ok(mockNotifications);
    }

    @PutMapping("/{id}/read")
    public ResponseEntity<Void> markAsRead(@PathVariable String id) {
        for (int i = 0; i < mockNotifications.size(); i++) {
            Map<String, Object> n = mockNotifications.get(i);
            if (id.equals(n.get("id"))) {
                mockNotifications.set(i, Map.of(
                    "id", n.get("id"),
                    "userId", n.get("userId"),
                    "title", n.get("title"),
                    "message", n.get("message"),
                    "type", n.get("type"),
                    "isRead", true,
                    "createdAt", n.get("createdAt")
                ));
                break;
            }
        }
        return ResponseEntity.ok().build();
    }
}
