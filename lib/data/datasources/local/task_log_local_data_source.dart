import '../../../domain/entities/task_log_entity.dart';
import '../../models/task_log_model.dart';
import 'database_helper.dart';

/// Local data source for task log operations
///
/// Task logs are append-only (immutable) by design
class TaskLogLocalDataSource {
  final DatabaseHelper _dbHelper;

  TaskLogLocalDataSource(this._dbHelper);

  /// Create a new task log entry (append-only)
  Future<void> createLog(TaskLogEntity log) async {
    final db = await _dbHelper.database;
    final model = TaskLogModel.fromEntity(log);
    await db.insert('task_logs', model.toMap());
  }

  /// Get all logs for a specific task
  Future<List<TaskLogEntity>> getLogsByTaskId(String taskId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'task_logs',
      where: 'task_id = ?',
      whereArgs: [taskId],
      orderBy: 'timestamp DESC',
    );
    return maps.map((map) => TaskLogModel.fromMap(map).toEntity()).toList();
  }

  /// Get all logs within a date range
  Future<List<TaskLogEntity>> getLogsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'task_logs',
      where: 'timestamp BETWEEN ? AND ?',
      whereArgs: [
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ],
      orderBy: 'timestamp DESC',
    );
    return maps.map((map) => TaskLogModel.fromMap(map).toEntity()).toList();
  }

  /// Get all logs
  Future<List<TaskLogEntity>> getAllLogs() async {
    final db = await _dbHelper.database;
    final maps = await db.query('task_logs', orderBy: 'timestamp DESC');
    return maps.map((map) => TaskLogModel.fromMap(map).toEntity()).toList();
  }

  /// Delete logs within a date range (controlled by settings)
  Future<void> deleteLogsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbHelper.database;
    await db.delete(
      'task_logs',
      where: 'timestamp BETWEEN ? AND ?',
      whereArgs: [
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ],
    );
  }

  /// Delete all logs (controlled by settings)
  Future<void> deleteAllLogs() async {
    final db = await _dbHelper.database;
    await db.delete('task_logs');
  }

  /// Get log count
  Future<int> getLogCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM task_logs');
    return result.first['count'] as int;
  }
}
