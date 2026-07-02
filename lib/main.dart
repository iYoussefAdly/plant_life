import 'package:flutter/material.dart';

import 'core/di/service_locator.dart';
import 'core/networking/socket_service.dart';
import 'core/routing/app_router.dart';
import 'core/routing/app_routes.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  // Redirect to login when a session expires (refresh failed), unless already
  // there — keeps the router dependency out of the DI layer.
  onSessionExpired = () {
    sl<SocketService>().disconnect();
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
