import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../networking/dio_factory.dart';
import '../storage/token_storage.dart';
import '../../features/auth/data/repos/auth_repository_impl.dart';
import '../../features/auth/domain/repos/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/home/data/repos/home_repository_impl.dart';
import '../../features/home/domain/repos/home_repository.dart';
import '../../features/home/domain/usecases/get_home_data_usecase.dart';
import '../../features/home/presentation/bloc/home_cubit.dart';
import '../../features/sensors/data/repos/sensors_repository_impl.dart';
import '../../features/sensors/domain/repos/sensors_repository.dart';
import '../../features/sensors/domain/usecases/get_sensors_data_usecase.dart';
import '../../features/sensors/presentation/bloc/sensors_cubit.dart';
import '../../features/scan/data/repos/scan_repository_impl.dart';
import '../../features/scan/domain/repos/scan_repository.dart';
import '../../features/scan/domain/usecases/get_scan_history_usecase.dart';
import '../../features/scan/domain/usecases/save_reminder_usecase.dart';
import '../../features/scan/domain/usecases/scan_image_usecase.dart';
import '../../features/scan/presentation/bloc/scan_cubit.dart';
import '../../features/treatments/data/repos/treatments_repository_impl.dart';
import '../../features/treatments/domain/repos/treatments_repository.dart';
import '../../features/treatments/domain/usecases/get_treatment_plans_usecase.dart';
import '../../features/treatments/domain/usecases/get_treatment_detail_usecase.dart';
import '../../features/treatments/domain/usecases/toggle_step_usecase.dart';
import '../../features/treatments/presentation/bloc/treatments_cubit.dart';
import '../../features/treatments/presentation/bloc/treatment_detail_cubit.dart';
import '../../features/recovery/data/repos/recovery_repository_impl.dart';
import '../../features/recovery/domain/repos/recovery_repository.dart';
import '../../features/recovery/domain/usecases/get_recovery_progress_usecase.dart';
import '../../features/recovery/presentation/bloc/recovery_cubit.dart';
import '../../features/notifications/data/repos/notifications_repository_impl.dart';
import '../../features/notifications/domain/repos/notifications_repository.dart';
import '../../features/notifications/domain/usecases/get_notifications_usecase.dart';
import '../../features/notifications/domain/usecases/mark_notification_read_usecase.dart';
import '../../features/notifications/presentation/bloc/notifications_cubit.dart';

final sl = GetIt.instance;

void setupServiceLocator() {
  // Core infrastructure (networking + secure storage)
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => TokenStorage(sl<FlutterSecureStorage>()));
  // TODO(auth): wire `onUnauthorized` to redirect to login (router navigatorKey)
  // when the Auth step lands, before real features consume this Dio instance.
  sl.registerLazySingleton<Dio>(
    () => DioFactory.create(tokenStorage: sl<TokenStorage>()),
  );

  // Auth
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
  sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => RegisterUseCase(sl<AuthRepository>()));
  sl.registerFactory(() => AuthCubit(sl<LoginUseCase>(), sl<RegisterUseCase>()));

  // Home
  sl.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl());
  sl.registerLazySingleton(() => GetHomeDataUseCase(sl<HomeRepository>()));
  sl.registerFactory(() => HomeCubit(sl<GetHomeDataUseCase>()));

  // Sensors
  sl.registerLazySingleton<SensorsRepository>(() => SensorsRepositoryImpl());
  sl.registerLazySingleton(() => GetSensorsDataUseCase(sl<SensorsRepository>()));
  sl.registerFactory(() => SensorsCubit(sl<GetSensorsDataUseCase>()));

  // Scan
  sl.registerLazySingleton<ScanRepository>(() => ScanRepositoryImpl());
  sl.registerLazySingleton(() => ScanImageUseCase(sl<ScanRepository>()));
  sl.registerLazySingleton(() => GetScanHistoryUseCase(sl<ScanRepository>()));
  sl.registerLazySingleton(() => SaveReminderUseCase(sl<ScanRepository>()));
  sl.registerFactory(() => ScanCubit(sl<ScanImageUseCase>(), sl<GetScanHistoryUseCase>(), sl<SaveReminderUseCase>()));

  // Treatments
  sl.registerLazySingleton<TreatmentsRepository>(() => TreatmentsRepositoryImpl());
  sl.registerLazySingleton(() => GetTreatmentPlansUseCase(sl<TreatmentsRepository>()));
  sl.registerLazySingleton(() => GetTreatmentDetailUseCase(sl<TreatmentsRepository>()));
  sl.registerLazySingleton(() => ToggleStepUseCase(sl<TreatmentsRepository>()));
  sl.registerFactory(() => TreatmentsCubit(sl<GetTreatmentPlansUseCase>()));
  sl.registerFactory(() => TreatmentDetailCubit(sl<GetTreatmentDetailUseCase>(), sl<ToggleStepUseCase>()));

  // Recovery
  sl.registerLazySingleton<RecoveryRepository>(() => RecoveryRepositoryImpl());
  sl.registerLazySingleton(() => GetRecoveryProgressUseCase(sl<RecoveryRepository>()));
  sl.registerFactory(() => RecoveryCubit(sl<GetRecoveryProgressUseCase>()));

  // Notifications
  sl.registerLazySingleton<NotificationsRepository>(() => NotificationsRepositoryImpl());
  sl.registerLazySingleton(() => GetNotificationsUseCase(sl<NotificationsRepository>()));
  sl.registerLazySingleton(() => MarkNotificationReadUseCase(sl<NotificationsRepository>()));
  sl.registerLazySingleton(() => NotificationsCubit(sl<GetNotificationsUseCase>(), sl<MarkNotificationReadUseCase>()));
}
