import '../../../../core/enums/plant_type.dart';
import '../../../../core/errors/api_result.dart';

abstract class AuthRepository {
  Future<ApiResult<void>> login({
    required String email,
    required String password,
  });

  Future<ApiResult<void>> register({
    required String name,
    required String email,
    required String password,
    required String deviceId,
    required PlantType selectedPlant,
  });
}
