import 'package:dio/dio.dart';

import '../../../../../core/networking/api_response_parser.dart';
import '../heal_plan_model.dart';

/// Parsed payload of `GET /heal-plans` (the list of the user's plans).
class HealPlansResponse {
  final List<HealPlanModel> plans;

  const HealPlansResponse({required this.plans});

  factory HealPlansResponse.fromResponse(Response response) {
    final data = ApiResponseParser.dataMap(response);
    final list = (data['healPlans'] ?? data['plans']) as List? ?? const [];
    return HealPlansResponse(
      plans: list
          .whereType<Map<String, dynamic>>()
          .map(HealPlanModel.fromJson)
          .where((p) => p.id.isNotEmpty)
          .toList(),
    );
  }
}
