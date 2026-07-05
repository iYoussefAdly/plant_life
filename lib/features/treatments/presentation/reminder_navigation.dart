import 'dart:convert';

import 'screens/treatment_detail_screen.dart';

/// Builds treatment-detail navigation args from a reminder notification
/// payload (`{"planId": ..., "stepId": ...}`), or null when the payload isn't a
/// valid treatment reminder. Shared by the cold-launch (splash) and running-app
/// (main) tap handlers.
TreatmentDetailArgs? treatmentArgsFromReminderPayload(String payload) {
  try {
    final data = jsonDecode(payload);
    if (data is! Map) return null;
    final planId = data['planId'];
    if (planId is! String || planId.isEmpty) return null;
    final stepId = data['stepId'];
    return TreatmentDetailArgs(
      planId: planId,
      highlightStepId: stepId is String ? stepId : null,
    );
  } catch (_) {
    return null;
  }
}
