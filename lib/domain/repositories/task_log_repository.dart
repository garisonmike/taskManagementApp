import '../entities/task_log_entity.dart';

/// Repository interface for task log operations
abstract class TaskLogRepository {
  /// Create a new log entry (append-only)
  Future<void> createLog(TaskLogEntity log);

  /// Get all logs for a specific task
  Future<List<TaskLogEntity>> getLogsByTaskId(String taskId);

  /// Get all logs within a date range
  Future<List<TaskLogEntity>> getLogsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Get all logs
  Future<List<TaskLogEntity>> getAllLogs();

  /// Delete logs within a date range (controlled by settings)
  Future<void> deleteLogsByDateRange(DateTime startDate, DateTime endDate);

  /// Delete all logs (controlled by settings)
  Future<void> deleteAllLogs();

  /// Get log count
  Future<int> getLogCount();
}
