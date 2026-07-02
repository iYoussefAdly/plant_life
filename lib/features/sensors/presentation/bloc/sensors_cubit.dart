import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/api_result.dart';
import '../../domain/usecases/get_sensors_data_usecase.dart';
import 'sensors_state.dart';

class SensorsCubit extends Cubit<SensorsState> {
  final GetSensorsDataUseCase _getSensorsDataUseCase;

  SensorsCubit(this._getSensorsDataUseCase) : super(const SensorsInitial());

  /// [silent] refreshes without flashing the loading placeholder (used by
  /// pull-to-refresh) and keeps the current data on a background failure.
  Future<void> loadSensorsData({bool silent = false}) async {
    if (!silent) emit(const SensorsLoading());
    final result = await _getSensorsDataUseCase();
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(SensorsSuccess(data));
      case Error(:final failure):
        if (!silent) emit(SensorsError(failure.message));
    }
  }
}
