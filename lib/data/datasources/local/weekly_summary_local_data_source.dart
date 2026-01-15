import 'package:sqflite/sqflite.dart';

import '../../models/weekly_summary_model.dart';
import 'database_helper.dart';

/// Local data source for weekly summaries with CRUD operations
class WeeklySummaryLocalDataSource {
  final DatabaseHelper _dbHelper;

  WeeklySummaryLocalDataSource({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  /// Create a new weekly summary
  Future<void> createSummary(WeeklySummaryModel summary) async {
    final db = await _dbHelper.database;
    await db.insert(
      'weekly_summaries',
      summary.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get a specific weekly summary by ID
  Future<WeeklySummaryModel?> getSummaryById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'weekly_summaries',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return WeeklySummaryModel.fromMap(maps.first);
  }

  /// Get weekly summary for a specific week start date
  Future<WeeklySummaryModel?> getSummaryByWeekStart(DateTime weekStart) async {
    final db = await _dbHelper.database;
    final weekStartStr = weekStart.toIso8601String();
    final List<Map<String, dynamic>> maps = await db.query(
      'weekly_summaries',
      where: 'week_start_date = ?',
      whereArgs: [weekStartStr],
    );

    if (maps.isEmpty) return null;
    return WeeklySummaryModel.fromMap(maps.first);
  }

  /// Get all weekly summaries ordered by week start date (descending)
  Future<List<WeeklySummaryModel>> getAllSummaries() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'weekly_summaries',
      orderBy: 'week_start_date DESC',
    );

    return maps.map((map) => WeeklySummaryModel.fromMap(map)).toList();
  }

  /// Get summaries within a date range
  Future<List<WeeklySummaryModel>> getSummariesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbHelper.database;
    final startStr = startDate.toIso8601String();
    final endStr = endDate.toIso8601String();

    final List<Map<String, dynamic>> maps = await db.query(
      'weekly_summaries',
      where: 'week_start_date >= ? AND week_start_date <= ?',
      whereArgs: [startStr, endStr],
      orderBy: 'week_start_date DESC',
    );

    return maps.map((map) => WeeklySummaryModel.fromMap(map)).toList();
  }

  /// Delete a weekly summary by ID
  Future<void> deleteSummary(String id) async {
    final db = await _dbHelper.database;
    await db.delete('weekly_summaries', where: 'id = ?', whereArgs: [id]);
  }

  /// Delete all weekly summaries
  Future<void> deleteAllSummaries() async {
    final db = await _dbHelper.database;
    await db.delete('weekly_summaries');
  }

  /// Get the count of all summaries
  Future<int> getSummaryCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM weekly_summaries',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
