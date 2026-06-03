import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/api_result.dart';
import '../../domain/usecases/get_sensors_data_usecase.dart';
import 'sensors_state.dart';

class SensorsCubit extends Cubit<SensorsState> {
  final GetSensorsDataUseCase _getSensorsDataUseCase;

  SensorsCubit(this._getSensorsDataUseCase) : super(const SensorsInitial());

  Future<void> loadSensorsData() async {
    emit(const SensorsLoading());
    final result = await _getSensorsDataUseCase();
    switch (result) {
      case Success(:final data):
        emit(SensorsSuccess(data));
      case Error(:final failure):
        emit(SensorsError(failure.message));
    }
  }
}
