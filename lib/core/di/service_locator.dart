import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../events/app_event_bus.dart';
import '../networking/dio_factory.dart';
import '../networking/socket_service.dart';
import '../storage/token_storage.dart';
import '../../features/auth/data/datasources/auth_data_source.dart';
import '../../features/auth/data/repos/auth_repository_impl.dart';
import '../../features/auth/domain/repos/auth_repository.dart';
import '../../features/auth/domain/usecases/get_me_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/profile/presentation/bloc/profile_cubit.dart';
import '../../features/home/data/repos/home_repository_impl.dart';
import '../../features/home/domain/repos/home_repository.dart';
import '../../features/home/domain/usecases/get_home_data_usecase.dart';
import '../../features/home/presentation/bloc/home_cubit.dart';
import '../../features/sensors/data/repos/sensors_repository_impl.dart';
import '../../features/sensors/domain/repos/sensors_repository.dart';
import '../../features/sensors/domain/usecases/get_sensors_data_usecase.dart';
import '../../features/sensors/presentation/bloc/sensors_cubit.dart';
import '../../features/scan/data/datasources/scan_data_source.dart';
import '../../features/scan/data/repos/scan_repository_impl.dart';
import '../../features/scan/domain/repos/scan_repository.dart';
import '../../features/scan/domain/usecases/get_scan_history_usecase.dart';
import '../../features/scan/domain/usecases/scan_image_usecase.dart';
import '../../features/scan/presentation/bloc/scan_cubit.dart';
import '../../features/treatments/data/datasources/treatments_data_source.dart';
import '../../features/treatments/data/repos/treatments_repository_impl.dart';
import '../../features/treatments/domain/repos/treatments_repository.dart';
import '../../features/treatments/domain/usecases/create_heal_plan_usecase.dart';
import '../../features/treatments/domain/usecases/get_treatment_plans_usecase.dart';
import '../../features/treatments/domain/usecases/get_treatment_detail_usecase.dart';
import '../../features/treatments/domain/usecases/toggle_step_usecase.dart';
import '../../features/treatments/presentation/bloc/treatments_cubit.dart';
import '../../features/treatments/presentation/bloc/treatment_detail_cubit.dart';
import '../../features/recovery/data/datasources/recovery_data_source.dart';
import '../../features/recovery/data/repos/recovery_repository_impl.dart';
import '../../features/recovery/domain/repos/recovery_repository.dart';
import '../../features/recovery/domain/usecases/create_rescan_usecase.dart';
import '../../features/recovery/domain/usecases/get_rescans_usecase.dart';
import '../../features/recovery/presentation/bloc/recovery_cubit.dart';
import '../../features/notifications/data/datasources/notifications_data_source.dart';
import '../../features/notifications/data/repos/notifications_repository_impl.dart';
import '../../features/notifications/domain/repos/notifications_repository.dart';
import '../../features/notifications/domain/usecases/get_notifications_usecase.dart';
import '../../features/notifications/domain/usecases/get_unread_count_usecase.dart';
import '../../features/notifications/domain/usecases/mark_notification_read_usecase.dart';
import '../../features/notifications/domain/usecases/watch_new_notifications_usecase.dart';
import '../../features/notifications/presentation/bloc/notifications_cubit.dart';

final sl = GetIt.instance;

/// Invoked when an authenticated request fails unrecoverably (refresh failed).
/// Wired in `main.dart` to redirect to login — kept as a late-bound hook so the
/// DI layer does not depend on the router (avoids a service_locator ↔ app_router
/// import cycle and keeps it swappable in tests).
void Function()? onSessionExpired;

void setupServiceLocator() {
  // Core infrastructure (networking + secure storage)
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => TokenStorage(sl<FlutterSecureStorage>()));
  sl.registerLazySingleton(() => SocketService(sl<TokenStorage>()));
  // App-wide bus for automatic cross-feature UI sync after data changes.
  sl.registerLazySingleton(() => AppEventBus());
  sl.registerLazySingleton<Dio>(
    () => DioFactory.create(
      tokenStorage: sl<TokenStorage>(),
      // On unrecoverable 401 (refresh failed), tokens are cleared and the
      // late-bound hook (set in main.dart) sends the user back to login.
      onUnauthorized: () => onSessionExpired?.call(),
    ),
  );

  // Auth
  sl.registerLazySingleton(() => AuthDataSource(sl<Dio>()));
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthDataSource>(), sl<TokenStorage>()),
  );
  sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => RegisterUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GetMeUseCase(sl<AuthRepository>()));
  sl.registerFactory(() => AuthCubit(
        sl<LoginUseCase>(),
        sl<RegisterUseCase>(),
        sl<LogoutUseCase>(),
      ));

  // Profile — intentionally a lazySingleton: the Home app-bar greeting/avatar
  // and the Profile screen share this instance (same pattern as
  // NotificationsCubit below).
  sl.registerLazySingleton(
    () => ProfileCubit(sl<GetMeUseCase>(), sl<LogoutUseCase>()),
  );

  // Home (Today's Tasks compose from the active heal plan; sensors stay mock)
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(sl<TreatmentsRepository>()),
  );
  sl.registerLazySingleton(() => GetHomeDataUseCase(sl<HomeRepository>()));
  sl.registerFactory(() => HomeCubit(sl<GetHomeDataUseCase>(), sl<AppEventBus>()));

  // Sensors
  sl.registerLazySingleton<SensorsRepository>(() => SensorsRepositoryImpl());
  sl.registerLazySingleton(() => GetSensorsDataUseCase(sl<SensorsRepository>()));
  sl.registerFactory(() => SensorsCubit(sl<GetSensorsDataUseCase>()));

  // Scan
  sl.registerLazySingleton(() => ScanDataSource(sl<Dio>()));
  sl.registerLazySingleton<ScanRepository>(
    () => ScanRepositoryImpl(sl<ScanDataSource>()),
  );
  sl.registerLazySingleton(() => ScanImageUseCase(sl<ScanRepository>()));
  sl.registerLazySingleton(() => GetScanHistoryUseCase(sl<ScanRepository>()));
  sl.registerFactory(() => ScanCubit(
        sl<ScanImageUseCase>(),
        sl<GetScanHistoryUseCase>(),
        sl<CreateHealPlanUseCase>(),
        sl<AppEventBus>(),
      ));

  // Treatments
  sl.registerLazySingleton(() => TreatmentsDataSource(sl<Dio>()));
  sl.registerLazySingleton<TreatmentsRepository>(
    () => TreatmentsRepositoryImpl(sl<TreatmentsDataSource>()),
  );
  sl.registerLazySingleton(() => GetTreatmentPlansUseCase(sl<TreatmentsRepository>()));
  sl.registerLazySingleton(() => GetTreatmentDetailUseCase(sl<TreatmentsRepository>()));
  sl.registerLazySingleton(() => ToggleStepUseCase(sl<TreatmentsRepository>()));
  sl.registerLazySingleton(() => CreateHealPlanUseCase(sl<TreatmentsRepository>()));
  sl.registerFactory(
    () => TreatmentsCubit(sl<GetTreatmentPlansUseCase>(), sl<AppEventBus>()),
  );
  sl.registerFactory(() => TreatmentDetailCubit(
        sl<GetTreatmentDetailUseCase>(),
        sl<ToggleStepUseCase>(),
        sl<AppEventBus>(),
      ));

  // Recovery
  sl.registerLazySingleton(() => RecoveryDataSource(sl<Dio>()));
  sl.registerLazySingleton<RecoveryRepository>(
    () => RecoveryRepositoryImpl(sl<RecoveryDataSource>()),
  );
  sl.registerLazySingleton(() => GetRescansUseCase(sl<RecoveryRepository>()));
  sl.registerLazySingleton(() => CreateRescanUseCase(sl<RecoveryRepository>()));
  sl.registerFactory(() => RecoveryCubit(
        sl<GetRescansUseCase>(),
        sl<CreateRescanUseCase>(),
        sl<AppEventBus>(),
      ));

  // Notifications
  sl.registerLazySingleton(
    () => NotificationsDataSource(sl<Dio>(), sl<SocketService>()),
  );
  sl.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(sl<NotificationsDataSource>()),
  );
  sl.registerLazySingleton(() => GetNotificationsUseCase(sl<NotificationsRepository>()));
  sl.registerLazySingleton(() => GetUnreadCountUseCase(sl<NotificationsRepository>()));
  sl.registerLazySingleton(() => MarkNotificationReadUseCase(sl<NotificationsRepository>()));
  sl.registerLazySingleton(() => WatchNewNotificationsUseCase(sl<NotificationsRepository>()));
  // Intentionally a lazySingleton (not a factory like other cubits): the home
  // app-bar badge and the notifications screen share this one instance so that
  // marking a notification read updates the badge. The profile logout flow
  // calls reset() on it so a new session starts clean.
  sl.registerLazySingleton(() => NotificationsCubit(
        sl<GetNotificationsUseCase>(),
        sl<GetUnreadCountUseCase>(),
        sl<MarkNotificationReadUseCase>(),
        sl<WatchNewNotificationsUseCase>(),
      ));
}
