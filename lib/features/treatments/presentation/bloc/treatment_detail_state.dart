import '../../domain/entities/treatment_plan_entity.dart';

sealed class TreatmentDetailState {
  const TreatmentDetailState();
}

final class TreatmentDetailInitial extends TreatmentDetailState {
  const TreatmentDetailInitial();
}

final class TreatmentDetailLoading extends TreatmentDetailState {
  const TreatmentDetailLoading();
}

final class TreatmentDetailSuccess extends TreatmentDetailState {
  final TreatmentPlanEntity plan;
  const TreatmentDetailSuccess(this.plan);
}

final class TreatmentDetailError extends TreatmentDetailState {
  final String message;
  const TreatmentDetailError(this.message);
}
