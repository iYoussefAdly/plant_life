import '../../domain/entities/sensors_data_entity.dart';

sealed class SensorsState {
  const SensorsState();
}

final class SensorsInitial extends SensorsState {
  const SensorsInitial();
}

/// No sensor Device ID configured yet — the feature is locked behind the
/// onboarding gate until the user enters one.
final class SensorsNeedsDeviceId extends SensorsState {
  const SensorsNeedsDeviceId();
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
