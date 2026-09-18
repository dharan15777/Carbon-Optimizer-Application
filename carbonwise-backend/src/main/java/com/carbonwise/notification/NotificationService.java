package com.carbonwise.notification;
import com.carbonwise.entity.Notification; import com.carbonwise.repository.NotificationRepository;
import lombok.RequiredArgsConstructor; import org.springframework.stereotype.Service;
import java.time.LocalDateTime;

@Service @RequiredArgsConstructor
public class NotificationService {
    private final NotificationRepository notificationRepository;
    public Notification createNotification(String userId, String type, String title, String message) {
        Notification notification = Notification.builder().userId(userId).type(type).title(title).message(message).isRead(false).createdAt(LocalDateTime.now()).build();
        return notificationRepository.save(notification);
    }
    public void sendGridCleanNotification(String userId) { createNotification(userId, "GRID_CLEAN", "Grid is Clean", "Renewable energy is high. Schedule heavy loads now!"); }
    public void sendGridDirtyNotification(String userId) { createNotification(userId, "GRID_DIRTY", "Grid is Dirty", "High carbon intensity detected. Avoid heavy loads."); }
    public void sendBestChargingNotification(String userId, String time) { createNotification(userId, "BEST_CHARGING", "Best Charging Time", "Optimal EV charging window: " + time); }
}
