import 'package:get_it/get_it.dart';

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
import '../../features/scan/domain/usecases/scan_image_usecase.dart';
import '../../features/scan/presentation/bloc/scan_cubit.dart';

final sl = GetIt.instance;

void setupServiceLocator() {
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
  sl.registerFactory(() => ScanCubit(sl<ScanImageUseCase>(), sl<GetScanHistoryUseCase>()));
}
