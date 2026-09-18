import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/notification_provider.dart';
import '../../models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<NotificationProvider>().fetchNotifications());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed: () {
              context.read<NotificationProvider>().markAllAsRead();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications marked as read'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 64, color: Colors.white.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  const Text('No notifications yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Real-time grid alerts will appear here', style: TextStyle(color: Colors.white54)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => context.read<NotificationProvider>().fetchNotifications(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: provider.notifications.length,
              itemBuilder: (context, index) => _buildNotificationCard(provider.notifications[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(CarbonNotification notification) {
    final iconData = _getNotificationIcon(notification.type);
    final color = _getNotificationColor(notification.type);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: notification.isRead ? AppTheme.cardDark : AppTheme.cardDark.withOpacity(0.95),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: notification.isRead ? Colors.transparent : color.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          if (!notification.isRead) {
            context.read<NotificationProvider>().markAsRead(notification.id);
          }
          _showNotificationDetail(notification);
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(iconData, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
                        color: notification.isRead ? Colors.white70 : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: const TextStyle(fontSize: 12, color: Colors.white54),
                    ),
                  ],
                ),
              ),
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationDetail(CarbonNotification notification) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getNotificationIcon(notification.type), color: _getNotificationColor(notification.type), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    notification.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(notification.message, style: const TextStyle(fontSize: 14, color: Colors.white70)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) => switch (type) {
        AppConstants.notifGridClean => Icons.bolt,
        AppConstants.notifGridDirty => Icons.warning,
        AppConstants.notifBestCharging => Icons.ev_station,
        AppConstants.notifDeviceCompleted => Icons.check_circle,
        AppConstants.notifHighPollution => Icons.cloud,
        AppConstants.notifWeatherAlert => Icons.storm,
        AppConstants.notifDailyReport => Icons.assessment,
        _ => Icons.notifications,
      };

  Color _getNotificationColor(String type) => switch (type) {
        AppConstants.notifGridClean => AppTheme.primaryGreen,
        AppConstants.notifGridDirty => AppTheme.primaryRed,
        AppConstants.notifBestCharging => AppTheme.primaryCyan,
        AppConstants.notifDeviceCompleted => AppTheme.primaryGreen,
        AppConstants.notifHighPollution => AppTheme.primaryRed,
        AppConstants.notifWeatherAlert => AppTheme.primaryYellow,
        AppConstants.notifDailyReport => AppTheme.primaryCyan,
        _ => Colors.white54,
      };
}
