import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../events/app_event_bus.dart';
import '../localization/locale_cubit.dart';
import '../networking/api_endpoints.dart';
import '../networking/dio_factory.dart';
import '../networking/socket_service.dart';
import '../notifications/local_notifications_service.dart';
import '../notifications/push_notifications_service.dart';
import '../storage/app_preferences.dart';
import '../storage/store_token_storage.dart';
import '../storage/token_storage.dart';
import '../../features/store/data/store_api_client.dart';
import '../../features/store/data/datasources/products_data_source.dart';
import '../../features/store/data/datasources/store_auth_data_source.dart';
import '../../features/store/data/datasources/cart_data_source.dart';
import '../../features/store/data/datasources/orders_data_source.dart';
import '../../features/store/data/repos/products_repository_impl.dart';
import '../../features/store/data/repos/store_session_repository_impl.dart';
import '../../features/store/data/repos/cart_repository_impl.dart';
import '../../features/store/data/repos/orders_repository_impl.dart';
import '../../features/store/domain/repos/products_repository.dart';
import '../../features/store/domain/repos/store_session_repository.dart';
import '../../features/store/domain/repos/cart_repository.dart';
import '../../features/store/domain/repos/orders_repository.dart';
import '../../features/store/domain/usecases/get_products_usecase.dart';
import '../../features/store/domain/usecases/get_product_usecase.dart';
import '../../features/store/domain/usecases/provision_store_session_usecase.dart';
import '../../features/store/domain/usecases/clear_store_session_usecase.dart';
import '../../features/store/domain/usecases/cart_usecases.dart';
import '../../features/store/domain/usecases/order_usecases.dart';
import '../../features/store/presentation/bloc/products_cubit.dart';
import '../../features/store/presentation/bloc/cart_cubit.dart';
import '../../features/store/presentation/bloc/orders_cubit.dart';
import '../../features/store/presentation/bloc/order_details_cubit.dart';
import '../../features/store/presentation/bloc/checkout_cubit.dart';
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
import '../../features/sensors/data/sensor_api_client.dart';
import '../../features/sensors/data/datasources/sensors_data_source.dart';
import '../../features/sensors/data/repos/sensors_repository_impl.dart';
import '../../features/sensors/domain/repos/sensors_repository.dart';
import '../../features/sensors/domain/usecases/get_sensor_notification_feed_usecase.dart';
import '../../features/sensors/domain/usecases/get_sensors_data_usecase.dart';
import '../../features/sensors/domain/usecases/mark_all_sensor_notifications_read_usecase.dart';
import '../../features/sensors/domain/usecases/mark_sensor_notification_read_usecase.dart';
import '../../features/sensors/domain/usecases/register_fcm_token_usecase.dart';
import '../../features/sensors/domain/usecases/register_sensor_device_usecase.dart';
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
import '../../features/treatments/domain/usecases/cancel_plan_usecase.dart';
import '../../features/treatments/domain/usecases/create_heal_plan_usecase.dart';
import '../../features/treatments/domain/usecases/get_task_detail_usecase.dart';
import '../../features/treatments/domain/services/treatment_reminder_scheduler.dart';
import '../../features/treatments/domain/usecases/get_treatment_plans_usecase.dart';
import '../../features/treatments/domain/usecases/get_treatment_detail_usecase.dart';
import '../../features/treatments/domain/usecases/sync_treatment_reminders_usecase.dart';
import '../../features/treatments/domain/usecases/toggle_step_usecase.dart';
import '../../features/treatments/data/services/treatment_reminder_scheduler_impl.dart';
import '../../features/treatments/presentation/bloc/task_detail_cubit.dart';
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
import '../../features/notifications/domain/usecases/get_treatment_reminders_usecase.dart';
import '../../features/notifications/domain/usecases/get_unread_count_usecase.dart';
import '../../features/notifications/domain/usecases/mark_all_notifications_read_usecase.dart';
import '../../features/notifications/domain/usecases/mark_notification_read_usecase.dart';
import '../../features/notifications/domain/usecases/watch_new_notifications_usecase.dart';
import '../../features/notifications/presentation/bloc/notifications_cubit.dart';

final sl = GetIt.instance;

/// Invoked when an authenticated request fails unrecoverably (refresh failed).
/// Wired in `main.dart` to redirect to login — kept as a late-bound hook so the
/// DI layer does not depend on the router (avoids a service_locator ↔ app_router
/// import cycle and keeps it swappable in tests).
void Function()? onSessionExpired;

Future<void> setupServiceLocator() async {
  // Core infrastructure (networking + secure storage)
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => TokenStorage(sl<FlutterSecureStorage>()));
  sl.registerLazySingleton(() => SocketService(sl<TokenStorage>()));
  // App-wide bus for automatic cross-feature UI sync after data changes.
  sl.registerLazySingleton(() => AppEventBus());

  // Local preferences (onboarding flag + language) and the app locale.
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => AppPreferences(prefs));
  sl.registerLazySingleton(() => LocaleCubit(sl<AppPreferences>()));

  // On-device notifications (scheduled treatment reminders). Registered here
  // but initialized from main() — DI setup stays free of async platform I/O
  // (so widget tests that only build the DI graph don't touch plugin channels).
  sl.registerLazySingleton(() => LocalNotificationsService());
  // Firebase Cloud Messaging (Sensor danger push alerts). Initialized from
  // main() like LocalNotificationsService — DI stays free of platform I/O.
  sl.registerLazySingleton(() => PushNotificationsService());

  // Store backend (separate host + token + Dio).
  sl.registerLazySingleton(
    () => StoreTokenStorage(sl<FlutterSecureStorage>()),
  );
  sl.registerLazySingleton(
    () => StoreDioFactory.create(sl<StoreTokenStorage>()),
  );
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
        sl<ProvisionStoreSessionUseCase>(),
        sl<RegisterFcmTokenUseCase>(),
        sl<PushNotificationsService>(),
      ));

  // Profile — intentionally a lazySingleton: the Home app-bar greeting/avatar
  // and the Profile screen share this instance (same pattern as
  // NotificationsCubit below).
  sl.registerLazySingleton(
    () => ProfileCubit(sl<GetMeUseCase>(), sl<LogoutUseCase>()),
  );

  // Home (Today's Tasks compose from the active heal plan; the sensor overview
  // + latest alerts come from the sensor backend once a Device ID is set).
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(
      sl<TreatmentsRepository>(),
      sl<SensorsRepository>(),
      sl<AppPreferences>(),
    ),
  );
  sl.registerLazySingleton(() => GetHomeDataUseCase(sl<HomeRepository>()));
  sl.registerFactory(() => HomeCubit(
        sl<GetHomeDataUseCase>(),
        sl<AppEventBus>(),
        sl<PushNotificationsService>(),
      ));

  // Sensors — separate backend host that reuses the main access token. A
  // dedicated refresh client points at the main API so 401s on sensor calls
  // refresh against /auth/refresh-token, then the sensor request is replayed.
  sl.registerLazySingleton<SensorApiClient>(
    () => SensorDioFactory.create(
      tokenStorage: sl<TokenStorage>(),
      refreshDio: Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl)),
      onUnauthorized: () => onSessionExpired?.call(),
    ),
  );
  sl.registerLazySingleton(() => SensorsDataSource(sl<SensorApiClient>()));
  sl.registerLazySingleton<SensorsRepository>(
    () => SensorsRepositoryImpl(sl<SensorsDataSource>()),
  );
  sl.registerLazySingleton(() => GetSensorsDataUseCase(sl<SensorsRepository>()));
  sl.registerLazySingleton(
    () => RegisterSensorDeviceUseCase(sl<SensorsRepository>()),
  );
  sl.registerLazySingleton(
    () => MarkSensorNotificationReadUseCase(sl<SensorsRepository>()),
  );
  sl.registerLazySingleton(
    () => MarkAllSensorNotificationsReadUseCase(sl<SensorsRepository>()),
  );
  sl.registerLazySingleton(
    () => RegisterFcmTokenUseCase(sl<SensorsRepository>()),
  );
  sl.registerLazySingleton(
    () => GetSensorNotificationFeedUseCase(sl<SensorsRepository>()),
  );
  sl.registerFactory(() => SensorsCubit(
        sl<GetSensorsDataUseCase>(),
        sl<RegisterSensorDeviceUseCase>(),
        sl<MarkSensorNotificationReadUseCase>(),
        sl<MarkAllSensorNotificationsReadUseCase>(),
        sl<AppPreferences>(),
        sl<PushNotificationsService>(),
        sl<AppEventBus>(),
      ));

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
  sl.registerLazySingleton(() => GetTaskDetailUseCase(sl<TreatmentsRepository>()));
  sl.registerLazySingleton(() => CancelPlanUseCase(sl<TreatmentsRepository>()));
  // On-device task reminders (scheduled locally; work with the app closed).
  sl.registerLazySingleton<TreatmentReminderScheduler>(
    () => TreatmentReminderSchedulerImpl(
      sl<LocalNotificationsService>(),
      sl<AppPreferences>(),
    ),
  );
  sl.registerLazySingleton(
    () => SyncTreatmentRemindersUseCase(sl<TreatmentReminderScheduler>()),
  );
  sl.registerFactory(
    () => TreatmentsCubit(
      sl<GetTreatmentPlansUseCase>(),
      sl<AppEventBus>(),
      sl<SyncTreatmentRemindersUseCase>(),
    ),
  );
  sl.registerFactory(() => TreatmentDetailCubit(
        sl<GetTreatmentDetailUseCase>(),
        sl<ToggleStepUseCase>(),
        sl<CancelPlanUseCase>(),
        sl<AppEventBus>(),
        sl<SyncTreatmentRemindersUseCase>(),
      ));
  sl.registerFactory(() => TaskDetailCubit(sl<GetTaskDetailUseCase>()));

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
  sl.registerLazySingleton(() => MarkAllNotificationsReadUseCase(sl<NotificationsRepository>()));
  sl.registerLazySingleton(() => WatchNewNotificationsUseCase(sl<NotificationsRepository>()));
  sl.registerLazySingleton(
    () => GetTreatmentRemindersUseCase(sl<TreatmentsRepository>()),
  );
  // Intentionally a lazySingleton (not a factory like other cubits): the home
  // app-bar badge and the notifications screen share this one instance so that
  // marking a notification read updates the badge. The profile logout flow
  // calls reset() on it so a new session starts clean.
  sl.registerLazySingleton(() => NotificationsCubit(
        sl<GetNotificationsUseCase>(),
        sl<GetUnreadCountUseCase>(),
        sl<MarkNotificationReadUseCase>(),
        sl<MarkAllNotificationsReadUseCase>(),
        sl<WatchNewNotificationsUseCase>(),
        sl<GetTreatmentRemindersUseCase>(),
        sl<GetSensorNotificationFeedUseCase>(),
        sl<MarkSensorNotificationReadUseCase>(),
        sl<MarkAllSensorNotificationsReadUseCase>(),
        sl<AppPreferences>(),
        sl<AppEventBus>(),
      ));

  // ---- Store (separate backend) ----
  // Store auth / session bridge
  sl.registerLazySingleton(() => StoreAuthDataSource(sl<StoreApiClient>()));
  sl.registerLazySingleton<StoreSessionRepository>(
    () => StoreSessionRepositoryImpl(
      sl<StoreAuthDataSource>(),
      sl<StoreTokenStorage>(),
    ),
  );
  sl.registerLazySingleton(
    () => ProvisionStoreSessionUseCase(sl<StoreSessionRepository>()),
  );
  sl.registerLazySingleton(
    () => ClearStoreSessionUseCase(sl<StoreSessionRepository>()),
  );

  // Products
  sl.registerLazySingleton(() => ProductsDataSource(sl<StoreApiClient>()));
  sl.registerLazySingleton<ProductsRepository>(
    () => ProductsRepositoryImpl(sl<ProductsDataSource>()),
  );
  sl.registerLazySingleton(() => GetProductsUseCase(sl<ProductsRepository>()));
  sl.registerLazySingleton(() => GetProductUseCase(sl<ProductsRepository>()));
  // Shared singleton (like CartCubit): the Store tab keeps its search/filter
  // state across navigation, and a "Search in Store" deep-link can drive it.
  sl.registerLazySingleton(() => ProductsCubit(sl<GetProductsUseCase>()));

  // Cart — shared singleton so the badge + cart screen stay in sync everywhere.
  sl.registerLazySingleton(() => CartDataSource(sl<StoreApiClient>()));
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(sl<CartDataSource>()),
  );
  sl.registerLazySingleton(() => GetCartUseCase(sl<CartRepository>()));
  sl.registerLazySingleton(() => AddToCartUseCase(sl<CartRepository>()));
  sl.registerLazySingleton(() => UpdateCartItemUseCase(sl<CartRepository>()));
  sl.registerLazySingleton(() => RemoveCartItemUseCase(sl<CartRepository>()));
  sl.registerLazySingleton(() => ClearCartUseCase(sl<CartRepository>()));
  sl.registerLazySingleton(() => CartCubit(
        sl<GetCartUseCase>(),
        sl<AddToCartUseCase>(),
        sl<UpdateCartItemUseCase>(),
        sl<RemoveCartItemUseCase>(),
        sl<ClearCartUseCase>(),
      ));

  // Orders + checkout
  sl.registerLazySingleton(() => OrdersDataSource(sl<StoreApiClient>()));
  sl.registerLazySingleton<OrdersRepository>(
    () => OrdersRepositoryImpl(sl<OrdersDataSource>()),
  );
  sl.registerLazySingleton(() => CreateOrderUseCase(sl<OrdersRepository>()));
  sl.registerLazySingleton(() => GetMyOrdersUseCase(sl<OrdersRepository>()));
  sl.registerLazySingleton(() => GetOrderUseCase(sl<OrdersRepository>()));
  sl.registerLazySingleton(
    () => CreateCheckoutSessionUseCase(sl<OrdersRepository>()),
  );
  sl.registerFactory(() => OrdersCubit(sl<GetMyOrdersUseCase>()));
  sl.registerFactory(() => OrderDetailsCubit(sl<GetOrderUseCase>()));
  sl.registerFactory(
    () => CheckoutCubit(
      sl<CreateOrderUseCase>(),
      sl<CreateCheckoutSessionUseCase>(),
    ),
  );
}
