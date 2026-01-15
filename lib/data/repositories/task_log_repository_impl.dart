import '../../domain/entities/task_log_entity.dart';
import '../../domain/repositories/task_log_repository.dart';
import '../datasources/local/task_log_local_data_source.dart';

/// Implementation of TaskLogRepository
class TaskLogRepositoryImpl implements TaskLogRepository {
  final TaskLogLocalDataSource _dataSource;

  TaskLogRepositoryImpl(this._dataSource);

  @override
  Future<void> createLog(TaskLogEntity log) async {
    await _dataSource.createLog(log);
  }

  @override
  Future<List<TaskLogEntity>> getLogsByTaskId(String taskId) async {
    return await _dataSource.getLogsByTaskId(taskId);
  }

  @override
  Future<List<TaskLogEntity>> getLogsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await _dataSource.getLogsByDateRange(startDate, endDate);
  }

  @override
  Future<List<TaskLogEntity>> getAllLogs() async {
    return await _dataSource.getAllLogs();
  }

  @override
  Future<void> deleteLogsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    await _dataSource.deleteLogsByDateRange(startDate, endDate);
  }

  @override
  Future<void> deleteAllLogs() async {
    await _dataSource.deleteAllLogs();
  }

  @override
  Future<int> getLogCount() async {
    return await _dataSource.getLogCount();
  }
}
