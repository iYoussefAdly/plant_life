import 'package:dio/dio.dart';

import '../../../../core/networking/api_endpoints.dart';
import '../../../../core/networking/api_response_parser.dart';
import '../models/heal_plan_model.dart';
import '../models/responses/heal_plans_response.dart';

/// Remote heal-plans API. Throws [DioException] on failure; the repository
/// maps those to typed failures at the boundary.
class TreatmentsDataSource {
  final Dio _dio;
  const TreatmentsDataSource(this._dio);

  Future<List<HealPlanModel>> getPlans({String? status}) async {
    final query = <String, dynamic>{};
    if (status != null) query['status'] = status;
    final response = await _dio.get<dynamic>(
      ApiEndpoints.healPlans,
      queryParameters: query.isEmpty ? null : query,
    );
    return HealPlansResponse.fromResponse(response).plans;
  }

  Future<HealPlanModel> getPlanDetail(String id) async {
    final response = await _dio.get<dynamic>(ApiEndpoints.healPlan(id));
    return _planFromResponse(response);
  }

  /// Toggles a task's completed state (the endpoint is a pure toggle — it
  /// takes no body) and returns the updated plan.
  Future<HealPlanModel> toggleTask(String planId, int taskIndex) async {
    final response = await _dio.patch<dynamic>(
      ApiEndpoints.toggleHealPlanTask(planId, taskIndex),
    );
    return _planFromResponse(response);
  }

  /// Handles both known single-plan envelope shapes: the plan nested under
  /// `data.healPlan` (as in accept-plan) or returned directly as `data`.
  HealPlanModel _planFromResponse(Response response) {
    final data = ApiResponseParser.dataMap(response);
    final plan = data['healPlan'];
    return HealPlanModel.fromJson(
      plan is Map<String, dynamic> ? plan : data,
    );
  }
}
