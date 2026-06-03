import '../../domain/entities/sensors_data_entity.dart';

sealed class SensorsState {
  const SensorsState();
}

final class SensorsInitial extends SensorsState {
  const SensorsInitial();
}

final class SensorsLoading extends SensorsState {
  const SensorsLoading();
}

final class SensorsSuccess extends SensorsState {
  final SensorsDataEntity data;
  const SensorsSuccess(this.data);
}

final class SensorsError extends SensorsState {
  final String message;
  const SensorsError(this.message);
}
