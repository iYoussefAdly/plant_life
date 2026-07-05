import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_routes.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/profile/presentation/bloc/profile_cubit.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/store/domain/usecases/get_product_usecase.dart';
import '../../features/store/presentation/bloc/cart_cubit.dart';
import '../../features/store/presentation/bloc/checkout_cubit.dart';
import '../../features/store/presentation/bloc/order_details_cubit.dart';
import '../../features/store/presentation/bloc/orders_cubit.dart';
import '../../features/store/presentation/bloc/products_cubit.dart';
import '../../features/store/presentation/screens/cart_screen.dart';
import '../../features/store/presentation/screens/checkout_screen.dart';
import '../../features/store/presentation/screens/order_details_screen.dart';
import '../../features/store/presentation/screens/orders_screen.dart';
import '../../features/store/presentation/screens/product_details_screen.dart';
import '../../features/store/presentation/screens/store_screen.dart';
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
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
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
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
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
          final extra = state.extra;
          final planId = switch (extra) {
            TreatmentDetailArgs(:final planId) => planId,
            String() => extra,
            _ => '',
          };
          final highlightStepId =
              extra is TreatmentDetailArgs ? extra.highlightStepId : null;
          return BlocProvider(
            create: (_) => sl<TreatmentDetailCubit>()..loadDetail(planId),
            child: TreatmentDetailScreen(highlightStepId: highlightStepId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.recoveryProgress,
        builder: (context, state) {
          final extra = state.extra;
          final args = extra is RecoveryArgs
              ? extra
              : RecoveryArgs(scanId: extra is String ? extra : '');
          return BlocProvider(
            create: (_) =>
                sl<RecoveryCubit>()..load(args.scanId, args.title),
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
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => BlocProvider.value(
          value: sl<ProfileCubit>()..loadProfile(),
          child: const ProfileScreen(),
        ),
      ),
      // ---- Store (product details / cart / checkout / orders are pushed over
      // the shell; the Store catalogue itself is a bottom-nav tab below) ----
      GoRoute(
        path: '${AppRoutes.productDetails}/:id',
        builder: (context, state) => BlocProvider.value(
          value: sl<CartCubit>(),
          child: ProductDetailsScreen(
            productId: state.pathParameters['id'] ?? '',
            getProduct: sl<GetProductUseCase>(),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.cart,
        builder: (context, state) => BlocProvider.value(
          value: sl<CartCubit>()..load(silent: true),
          child: const CartScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.checkout,
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: sl<CartCubit>()),
            BlocProvider(create: (_) => sl<CheckoutCubit>()),
          ],
          child: const CheckoutScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.orders,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<OrdersCubit>()..load(),
          child: const OrdersScreen(),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.orderDetails}/:id',
        builder: (context, state) => BlocProvider(
          create: (_) =>
              sl<OrderDetailsCubit>()..load(state.pathParameters['id'] ?? ''),
          child: const OrderDetailsScreen(),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MultiBlocProvider(
            providers: [
              BlocProvider.value(
                value: sl<NotificationsCubit>()..loadNotifications(),
              ),
              // Shared with the profile route so the Home greeting/avatar and
              // the Profile screen read the same user state.
              BlocProvider.value(value: sl<ProfileCubit>()..loadProfile()),
            ],
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
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.store,
                builder: (context, state) => MultiBlocProvider(
                  providers: [
                    // Shared singletons: the Store tab preserves its
                    // search/filter state and cart badge across navigation.
                    BlocProvider.value(
                      value: sl<ProductsCubit>()..ensureLoaded(),
                    ),
                    BlocProvider.value(
                      value: sl<CartCubit>()..load(silent: true),
                    ),
                  ],
                  child: const StoreScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
