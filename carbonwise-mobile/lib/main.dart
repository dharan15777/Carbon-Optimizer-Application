import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'repositories/auth_repository.dart';
import 'repositories/carbon_repository.dart';
import 'repositories/device_repository.dart';
import 'repositories/prediction_repository.dart';
import 'repositories/sensor_repository.dart';
import 'repositories/report_repository.dart';
import 'repositories/notification_repository.dart';
import 'repositories/map_repository.dart';
import 'providers/auth_provider.dart';
import 'providers/carbon_provider.dart';
import 'providers/device_provider.dart';
import 'providers/prediction_provider.dart';
import 'providers/sensor_provider.dart';
import 'providers/report_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/map_provider.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  // Initialize local notification service safely without throwing on unsupported platforms
  try {
    await NotificationService.instance.initialize();
  } catch (e) {
    debugPrint('NotificationService initialization skipped/failed: $e');
  }

  runApp(const CarbonWiseApp());
}

class CarbonWiseApp extends StatelessWidget {
  const CarbonWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();
    final authService = AuthService(apiService);

    return MultiProvider(
      providers: [
        // Services
        Provider<ApiService>.value(value: apiService),
        Provider<AuthService>.value(value: authService),

        // Repositories
        Provider<AuthRepository>(create: (_) => AuthRepository(authService)),
        Provider<CarbonRepository>(create: (_) => CarbonRepository(apiService)),
        Provider<DeviceRepository>(create: (_) => DeviceRepository(apiService)),
        Provider<PredictionRepository>(create: (_) => PredictionRepository(apiService)),
        Provider<SensorRepository>(create: (_) => SensorRepository(apiService)),
        Provider<ReportRepository>(create: (_) => ReportRepository(apiService)),
        Provider<NotificationRepository>(create: (_) => NotificationRepository(apiService)),
        Provider<MapRepository>(create: (_) => MapRepository(apiService)),

        // Providers
        ChangeNotifierProvider(create: (ctx) => AuthProvider(ctx.read<AuthRepository>())),
        ChangeNotifierProvider(create: (ctx) => CarbonProvider(ctx.read<CarbonRepository>())),
        ChangeNotifierProvider(create: (ctx) => DeviceProvider(ctx.read<DeviceRepository>())),
        ChangeNotifierProvider(create: (ctx) => PredictionProvider(ctx.read<PredictionRepository>())),
        ChangeNotifierProvider(create: (ctx) => SensorProvider(ctx.read<SensorRepository>())),
        ChangeNotifierProvider(create: (ctx) => ReportProvider(ctx.read<ReportRepository>())),
        ChangeNotifierProvider(create: (ctx) => NotificationProvider(ctx.read<NotificationRepository>())),
        ChangeNotifierProvider(create: (ctx) => MapProvider(ctx.read<MapRepository>())),
      ],
      child: MaterialApp.router(
        title: 'CarbonWise',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
