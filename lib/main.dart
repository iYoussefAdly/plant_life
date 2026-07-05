import 'package:flutter/material.dart';

import 'core/di/service_locator.dart';
import 'core/networking/socket_service.dart';
import 'core/routing/app_router.dart';
import 'core/routing/app_routes.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/notifications/presentation/bloc/notifications_cubit.dart';
import 'features/store/domain/usecases/clear_store_session_usecase.dart';
import 'features/store/presentation/bloc/cart_cubit.dart';
import 'features/store/presentation/bloc/products_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  // Redirect to login when a session expires (refresh failed), unless already
  // there — keeps the router dependency out of the DI layer.
  onSessionExpired = () {
    sl<SocketService>().disconnect();
    // Clear per-session state so the next user starts clean — mirrors the
    // explicit logout flow in ProfileScreen.
    sl<NotificationsCubit>().reset();
    sl<ClearStoreSessionUseCase>()();
    sl<CartCubit>().reset();
    sl<ProductsCubit>().reset();
    final path =
        AppRouter.router.routerDelegate.currentConfiguration.uri.path;
    if (path != AppRoutes.login) {
      AppRouter.router.go(AppRoutes.login);
    }
  };
  // Open the realtime connection if the user is already signed in.
  sl<TokenStorage>().hasTokens().then((hasTokens) {
    if (hasTokens) sl<SocketService>().connect();
  });
  runApp(const PlantLife());
}

class PlantLife extends StatelessWidget {
  const PlantLife({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PlantLife',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
    );
  }
}
