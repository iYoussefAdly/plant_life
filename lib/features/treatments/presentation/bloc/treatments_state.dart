import '../../domain/entities/treatment_plan_entity.dart';

sealed class TreatmentsState {
  const TreatmentsState();
}

final class TreatmentsInitial extends TreatmentsState {
  const TreatmentsInitial();
}

final class TreatmentsLoading extends TreatmentsState {
  const TreatmentsLoading();
}

final class TreatmentsSuccess extends TreatmentsState {
  final List<TreatmentPlanEntity> plans;
  const TreatmentsSuccess(this.plans);
}

final class TreatmentsError extends TreatmentsState {
  final String message;
  const TreatmentsError(this.message);
}
