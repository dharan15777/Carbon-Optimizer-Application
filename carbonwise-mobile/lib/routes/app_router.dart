import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/authentication/login_screen.dart';
import '../screens/authentication/register_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/prediction/prediction_screen.dart';
import '../screens/appliances/appliances_screen.dart';
import '../screens/scheduler/scheduler_screen.dart';
import '../screens/maps/maps_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/admin/admin_screen.dart';
import '../widgets/main_shell.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    routes: [
      // Auth routes (no shell)
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      // Shell routes (with bottom navigation)
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/prediction',
            builder: (context, state) => const PredictionScreen(),
          ),
          GoRoute(
            path: '/appliances',
            builder: (context, state) => const AppliancesScreen(),
          ),
          GoRoute(
            path: '/scheduler',
            builder: (context, state) => const SchedulerScreen(),
          ),
          GoRoute(
            path: '/maps',
            builder: (context, state) => const MapsScreen(),
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) => const ReportsScreen(),
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/admin',
            builder: (context, state) => const AdminScreen(),
          ),
        ],
      ),
    ],
  );
}
