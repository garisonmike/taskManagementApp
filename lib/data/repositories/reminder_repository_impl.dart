import '../../domain/entities/reminder_entity.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../datasources/local/reminder_local_data_source.dart';
import '../models/reminder_model.dart';

/// Implementation of reminder repository
class ReminderRepositoryImpl implements ReminderRepository {
  final ReminderLocalDataSource _localDataSource;

  ReminderRepositoryImpl({ReminderLocalDataSource? localDataSource})
    : _localDataSource = localDataSource ?? ReminderLocalDataSource();

  @override
  Future<List<ReminderEntity>> getAllReminders() async {
    final models = await _localDataSource.getAllReminders();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<ReminderEntity>> getRemindersByTaskId(String taskId) async {
    final models = await _localDataSource.getRemindersByTaskId(taskId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<ReminderEntity>> getRemindersByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final models = await _localDataSource.getRemindersByDateRange(
      startDate: startDate,
      endDate: endDate,
    );
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<ReminderEntity?> getReminderById(String id) async {
    final model = await _localDataSource.getReminderById(id);
    return model?.toEntity();
  }

  @override
  Future<void> addReminder(ReminderEntity reminder) async {
    final model = ReminderModel.fromEntity(reminder);
    await _localDataSource.insertReminder(model);
  }

  @override
  Future<void> updateReminder(ReminderEntity reminder) async {
    final model = ReminderModel.fromEntity(reminder);
    await _localDataSource.updateReminder(model);
  }

  @override
  Future<void> deleteReminder(String id) async {
    await _localDataSource.deleteReminder(id);
  }

  @override
  Future<void> deleteRemindersByTaskId(String taskId) async {
    await _localDataSource.deleteRemindersByTaskId(taskId);
  }
}
