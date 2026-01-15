import '../../domain/entities/meal_log_entity.dart';
import '../datasources/local/meal_log_local_data_source.dart';
import '../models/meal_log_model.dart';

/// Repository for meal log operations (immutable logs)
class MealLogRepository {
  final MealLogLocalDataSource _localDataSource;

  MealLogRepository(this._localDataSource);

  /// Create a new meal log entry
  Future<void> createLog(MealLogEntity log) async {
    final model = MealLogModel.fromEntity(log);
    await _localDataSource.createLog(model);
  }

  /// Get all meal logs
  Future<List<MealLogEntity>> getAllLogs() async {
    final models = await _localDataSource.getAllLogs();
    return models.map((model) => model.toEntity()).toList();
  }

  /// Get logs by meal ID
  Future<List<MealLogEntity>> getLogsByMealId(String mealId) async {
    final models = await _localDataSource.getLogsByMealId(mealId);
    return models.map((model) => model.toEntity()).toList();
  }

  /// Get logs by date range
  Future<List<MealLogEntity>> getLogsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final models = await _localDataSource.getLogsByDateRange(
      startDate: startDate,
      endDate: endDate,
    );
    return models.map((model) => model.toEntity()).toList();
  }

  /// Delete logs older than a certain date
  Future<void> deleteLogsOlderThan(DateTime date) async {
    await _localDataSource.deleteLogsOlderThan(date);
  }

  /// Delete all meal logs
  Future<void> deleteAllLogs() async {
    await _localDataSource.deleteAllLogs();
  }
}
