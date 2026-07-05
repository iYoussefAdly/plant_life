import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

import 'core/di/service_locator.dart';
import 'core/localization/l10n.dart';
import 'core/localization/locale_cubit.dart';
import 'core/networking/socket_service.dart';
import 'core/routing/app_router.dart';
import 'core/routing/app_routes.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/notifications/presentation/bloc/notifications_cubit.dart';
import 'features/store/domain/usecases/clear_store_session_usecase.dart';
import 'features/store/presentation/bloc/cart_cubit.dart';
import 'features/store/presentation/bloc/products_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
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
    return BlocProvider.value(
      value: sl<LocaleCubit>(),
      child: BlocBuilder<LocaleCubit, Locale?>(
        builder: (context, locale) => MaterialApp.router(
          title: 'PlantLife',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          // null = follow the system locale until the user picks a language.
          locale: locale,
          supportedLocales: LocaleCubit.supported,
          localeResolutionCallback: (device, supported) {
            final resolved = supported.firstWhere(
              (l) => l.languageCode == (locale ?? device)?.languageCode,
              orElse: () => supported.first,
            );
            // Keep context-free intl formatting (dates/prices) in the same
            // locale as the UI, including the follow-system case.
            Intl.defaultLocale = resolved.languageCode;
            return resolved;
          },
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}
