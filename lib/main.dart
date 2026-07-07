import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

import 'core/di/service_locator.dart';
import 'core/localization/l10n.dart';
import 'core/localization/locale_cubit.dart';
import 'core/networking/socket_service.dart';
import 'core/notifications/local_notifications_service.dart';
import 'core/notifications/push_notifications_service.dart';
import 'core/routing/app_router.dart';
import 'core/routing/app_routes.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/notifications/presentation/bloc/notifications_cubit.dart';
import 'features/sensors/domain/usecases/register_fcm_token_usecase.dart';
import 'features/store/domain/usecases/clear_store_session_usecase.dart';
import 'features/store/presentation/bloc/cart_cubit.dart';
import 'features/store/presentation/bloc/products_cubit.dart';
import 'features/treatments/presentation/reminder_navigation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  // Initialize on-device notifications (timezone, channel, permissions, and
  // capture of any reminder that cold-launched the app) before the UI starts.
  await sl<LocalNotificationsService>().init();
  // Initialize Firebase Cloud Messaging (Sensor danger push alerts, Android
  // only). Best-effort — the app runs normally if push is unavailable.
  await sl<PushNotificationsService>().init();
  // Re-register the FCM token with the backend whenever it rotates.
  sl<PushNotificationsService>().onTokenRefresh.listen((token) async {
    if (token.isEmpty) return;
    if (await sl<TokenStorage>().hasTokens()) {
      await sl<RegisterFcmTokenUseCase>()(token);
    }
  });
  // A sensor push is a new sensor alert — refresh the global notifications
  // center so the badge/list reflect it immediately.
  Future<void> refreshNotificationsOnPush(_) async {
    if (await sl<TokenStorage>().hasTokens()) {
      sl<NotificationsCubit>().loadNotifications(silent: true);
    }
  }

  sl<PushNotificationsService>()
      .onForegroundMessage
      .listen(refreshNotificationsOnPush);
  sl<PushNotificationsService>().onOpened.listen(refreshNotificationsOnPush);
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
    // Drop the previous user's scheduled reminders so they never fire for the
    // next account on this device.
    sl<LocalNotificationsService>().cancelAll();
    final path =
        AppRouter.router.routerDelegate.currentConfiguration.uri.path;
    if (path != AppRoutes.login) {
      AppRouter.router.go(AppRoutes.login);
    }
  };
  // Open a tapped reminder while the app is running (foreground/background).
  sl<LocalNotificationsService>().onTap.listen(_openReminder);
  // Open the realtime connection + register push for an already-signed-in user.
  sl<TokenStorage>().hasTokens().then((hasTokens) {
    if (!hasTokens) return;
    sl<SocketService>().connect();
    _registerFcmTokenOnStartup();
  });
  runApp(const PlantLife());
}

/// Registers the current FCM token for a user who is already signed in when the
/// app launches (login-time registration is handled by [AuthCubit]).
Future<void> _registerFcmTokenOnStartup() async {
  final token = await sl<PushNotificationsService>().getToken();
  if (token == null || token.isEmpty) return;
  await sl<RegisterFcmTokenUseCase>()(token);
}

/// Routes a tapped reminder to its treatment plan/task, but only for a
/// signed-in user (otherwise the tap is ignored and normal launch flow runs).
Future<void> _openReminder(String payload) async {
  final args = treatmentArgsFromReminderPayload(payload);
  if (args == null) return;
  if (!await sl<TokenStorage>().hasTokens()) return;
  AppRouter.router.push(AppRoutes.treatmentDetail, extra: args);
}

class PlantLife extends StatelessWidget {
  const PlantLife({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<LocaleCubit>(),
      child: BlocBuilder<LocaleCubit, Locale?>(
        builder: (context, locale) => MaterialApp.router(
          title: 'Plant Life',
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
