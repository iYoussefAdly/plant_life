import '../../domain/entities/recovery_entity.dart';

sealed class RecoveryState {
  const RecoveryState();
}

final class RecoveryInitial extends RecoveryState {
  const RecoveryInitial();
}

final class RecoveryLoading extends RecoveryState {
  const RecoveryLoading();
}

final class RecoverySuccess extends RecoveryState {
  final RecoveryEntity data;
  const RecoverySuccess(this.data);
}

final class RecoveryError extends RecoveryState {
  final String message;
  const RecoveryError(this.message);
}
