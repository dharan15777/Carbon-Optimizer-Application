import '../core/constants/app_constants.dart';
import '../services/api_service.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final ApiService _apiService;
  List<CarbonNotification> _localNotifications = [
    CarbonNotification(
      id: 'notif-1',
      userId: 'user-1',
      title: 'Optimal Green Charging Active',
      message: 'Grid carbon intensity is currently low (118 gCO₂/kWh). Excellent time to charge EV.',
      type: AppConstants.notifGridClean,
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
    ),
    CarbonNotification(
      id: 'notif-2',
      userId: 'user-1',
      title: 'AI Scheduled Smart Cycle',
      message: 'Smart Washing Machine scheduled for 1:30 PM today during peak renewable window.',
      type: AppConstants.notifBestCharging,
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    CarbonNotification(
      id: 'notif-3',
      userId: 'user-1',
      title: 'Air Quality Normal',
      message: 'All localized IoT environmental sensors are online and within clean thresholds.',
      type: AppConstants.notifDeviceCompleted,
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    CarbonNotification(
      id: 'notif-4',
      userId: 'user-1',
      title: 'Daily Carbon Savings Report Ready',
      message: 'You reduced your carbon footprint by 30% yesterday. View your full report now.',
      type: AppConstants.notifDailyReport,
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  NotificationRepository(this._apiService);

  Future<List<CarbonNotification>> fetchNotifications() async {
    try {
      final response = await _apiService.get('/api/notifications');
      if (response.data is List) {
        final list = (response.data as List).map((e) => CarbonNotification.fromJson(e)).toList();
        if (list.isNotEmpty) {
          _localNotifications = list;
          return list;
        }
      }
    } catch (_) {}
    return List<CarbonNotification>.from(_localNotifications);
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiService.put('/api/notifications/$notificationId/read');
    } catch (_) {}
    final idx = _localNotifications.indexWhere((n) => n.id == notificationId);
    if (idx != -1) {
      final existing = _localNotifications[idx];
      _localNotifications[idx] = CarbonNotification(
        id: existing.id,
        userId: existing.userId,
        title: existing.title,
        message: existing.message,
        type: existing.type,
        isRead: true,
        createdAt: existing.createdAt,
      );
    }
  }

  Future<void> markAllAsRead() async {
    for (int i = 0; i < _localNotifications.length; i++) {
      final existing = _localNotifications[i];
      _localNotifications[i] = CarbonNotification(
        id: existing.id,
        userId: existing.userId,
        title: existing.title,
        message: existing.message,
        type: existing.type,
        isRead: true,
        createdAt: existing.createdAt,
      );
    }
  }

  Future<int> fetchUnreadCount() async {
    final notifications = await fetchNotifications();
    return notifications.where((n) => !n.isRead).length;
  }
}
