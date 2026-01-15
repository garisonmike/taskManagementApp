import '../../models/meal_log_model.dart';
import 'database_helper.dart';

/// Local data source for meal logs (append-only)
class MealLogLocalDataSource {
  final DatabaseHelper _dbHelper;

  MealLogLocalDataSource(this._dbHelper);

  /// Create a new meal log entry
  Future<void> createLog(MealLogModel log) async {
    final db = await _dbHelper.database;
    await db.insert('meal_logs', log.toMap());
  }

  /// Get all meal logs
  Future<List<MealLogModel>> getAllLogs() async {
    final db = await _dbHelper.database;
    final maps = await db.query('meal_logs', orderBy: 'timestamp DESC');
    return maps.map((map) => MealLogModel.fromMap(map)).toList();
  }

  /// Get logs by meal ID
  Future<List<MealLogModel>> getLogsByMealId(String mealId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'meal_logs',
      where: 'meal_id = ?',
      whereArgs: [mealId],
      orderBy: 'timestamp DESC',
    );
    return maps.map((map) => MealLogModel.fromMap(map)).toList();
  }

  /// Get logs by date range
  Future<List<MealLogModel>> getLogsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'meal_logs',
      where: 'timestamp >= ? AND timestamp <= ?',
      whereArgs: [
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ],
      orderBy: 'timestamp DESC',
    );
    return maps.map((map) => MealLogModel.fromMap(map)).toList();
  }

  /// Delete logs older than a certain date
  Future<void> deleteLogsOlderThan(DateTime date) async {
    final db = await _dbHelper.database;
    await db.delete(
      'meal_logs',
      where: 'timestamp < ?',
      whereArgs: [date.millisecondsSinceEpoch],
    );
  }

  /// Delete all meal logs
  Future<void> deleteAllLogs() async {
    final db = await _dbHelper.database;
    await db.delete('meal_logs');
  }
}
