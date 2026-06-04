import '../../../../core/errors/api_result.dart';
import '../entities/reminder_entity.dart';
import '../repos/scan_repository.dart';

class SaveReminderUseCase {
  final ScanRepository _repository;

  SaveReminderUseCase(this._repository);

  Future<ApiResult<void>> call(ReminderEntity reminder) {
    return _repository.saveReminder(reminder);
  }
}
