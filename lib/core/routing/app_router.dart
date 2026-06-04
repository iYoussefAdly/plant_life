import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_routes.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/home/presentation/bloc/home_cubit.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/main_shell/presentation/main_shell.dart';
import '../../features/sensors/presentation/bloc/sensors_cubit.dart';
import '../../features/scan/presentation/bloc/scan_cubit.dart';
import '../../features/scan/presentation/screens/scan_screen.dart';
import '../../features/sensors/presentation/screens/sensors_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/treatments/presentation/bloc/treatments_cubit.dart';
import '../../features/treatments/presentation/bloc/treatment_detail_cubit.dart';
import '../../features/treatments/presentation/screens/treatments_screen.dart';
import '../../features/treatments/presentation/screens/treatment_detail_screen.dart';
import '../../features/recovery/presentation/bloc/recovery_cubit.dart';
import '../../features/recovery/presentation/screens/recovery_progress_screen.dart';
import '../../features/notifications/presentation/bloc/notifications_cubit.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../di/service_locator.dart';

abstract final class AppRouter {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.treatmentDetail,
        builder: (context, state) {
          final planId = state.extra is String ? state.extra as String : '';
          return BlocProvider(
            create: (_) => sl<TreatmentDetailCubit>()..loadDetail(planId),
            child: const TreatmentDetailScreen(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.recoveryProgress,
        builder: (context, state) {
          final treatmentId = state.extra is String ? state.extra as String : '';
          return BlocProvider(
            create: (_) => sl<RecoveryCubit>()..loadRecovery(treatmentId),
            child: const RecoveryProgressScreen(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => BlocProvider.value(
          value: sl<NotificationsCubit>(),
          child: const NotificationsScreen(),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return BlocProvider.value(
            value: sl<NotificationsCubit>()..loadNotifications(),
            child: MainShell(navigationShell: navigationShell),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => BlocProvider(
                  create: (_) => sl<HomeCubit>()..loadHomeData(),
                  child: const HomeScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.sensors,
                builder: (context, state) => BlocProvider(
                  create: (_) => sl<SensorsCubit>()..loadSensorsData(),
                  child: const SensorsScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.scan,
                builder: (context, state) => BlocProvider(
                  create: (_) => sl<ScanCubit>(),
                  child: const ScanScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.treatments,
                builder: (context, state) => BlocProvider(
                  create: (_) => sl<TreatmentsCubit>()..loadPlans(),
                  child: const TreatmentsScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
