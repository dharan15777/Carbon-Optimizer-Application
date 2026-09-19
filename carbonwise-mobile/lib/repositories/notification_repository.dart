import '../core/constants/app_constants.dart';
import '../services/api_service.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final ApiService _apiService;
  List<CarbonNotification> _localNotifications = [
    CarbonNotification(
      id: 'notif-1',
      userId: 'user-1',
      title: 'HIGH CARBON GRID ALERT',
      message: 'Grid intensity reached 642 g CO₂/kWh. Defer non-critical heating cycles.',
      type: AppConstants.notifGridDirty,
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
    ),
    CarbonNotification(
      id: 'notif-2',
      userId: 'user-1',
      title: 'CLEAN ENERGY WINDOW',
      message: 'Grid intensity dropped below 350 g CO₂/kWh. Solar peak active now.',
      type: AppConstants.notifGridClean,
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    CarbonNotification(
      id: 'notif-3',
      userId: 'user-1',
      title: 'MACHINE RISK',
      message: 'Industrial Furnace temperature exceeded safe operating threshold (840°C).',
      type: AppConstants.notifDeviceCompleted,
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 20)),
    ),
    CarbonNotification(
      id: 'notif-4',
      userId: 'user-1',
      title: 'AIR QUALITY WARNING',
      message: 'PM2.5 exceeded 75 µg/m³ in Machining Hall Bay 1. Exhaust fan boost active.',
      type: AppConstants.notifHighPollution,
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    CarbonNotification(
      id: 'notif-5',
      userId: 'user-1',
      title: 'OPTIMIZATION COMPLETE',
      message: '₹8.4L investment can reduce estimated annual emissions by 18.6% (142 t CO₂).',
      type: AppConstants.notifBestCharging,
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    CarbonNotification(
      id: 'notif-6',
      userId: 'user-1',
      title: 'REPORT READY',
      message: 'Monthly carbon audit report is ready for download in standard PDF format.',
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
    try {
      await _apiService.put('/api/notifications/read-all');
    } catch (_) {}
    _localNotifications = _localNotifications
        .map((n) => CarbonNotification(
              id: n.id,
              userId: n.userId,
              title: n.title,
              message: n.message,
              type: n.type,
              isRead: true,
              createdAt: n.createdAt,
            ))
        .toList();
  }
}
