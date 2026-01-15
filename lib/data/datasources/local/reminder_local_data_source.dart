import 'package:sqflite/sqflite.dart';

import '../../models/reminder_model.dart';
import 'database_helper.dart';

/// Local data source for reminder operations
class ReminderLocalDataSource {
  final DatabaseHelper _dbHelper;

  ReminderLocalDataSource({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  /// Get all reminders
  Future<List<ReminderModel>> getAllReminders() async {
    final db = await _dbHelper.database;
    final maps = await db.query('reminders', orderBy: 'reminder_time ASC');
    return maps.map((map) => ReminderModel.fromMap(map)).toList();
  }

  /// Get reminders for a specific task
  Future<List<ReminderModel>> getRemindersByTaskId(String taskId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'reminders',
      where: 'task_id = ?',
      whereArgs: [taskId],
      orderBy: 'reminder_time ASC',
    );
    return maps.map((map) => ReminderModel.fromMap(map)).toList();
  }

  /// Get reminders for a specific date range
  Future<List<ReminderModel>> getRemindersByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'reminders',
      where: 'reminder_time >= ? AND reminder_time < ?',
      whereArgs: [
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ],
      orderBy: 'reminder_time ASC',
    );
    return maps.map((map) => ReminderModel.fromMap(map)).toList();
  }

  /// Get reminder by ID
  Future<ReminderModel?> getReminderById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'reminders',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return ReminderModel.fromMap(maps.first);
  }

  /// Insert a new reminder
  Future<void> insertReminder(ReminderModel reminder) async {
    final db = await _dbHelper.database;
    await db.insert(
      'reminders',
      reminder.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update an existing reminder
  Future<void> updateReminder(ReminderModel reminder) async {
    final db = await _dbHelper.database;
    await db.update(
      'reminders',
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  /// Delete a reminder
  Future<void> deleteReminder(String id) async {
    final db = await _dbHelper.database;
    await db.delete('reminders', where: 'id = ?', whereArgs: [id]);
  }

  /// Delete all reminders for a task
  Future<void> deleteRemindersByTaskId(String taskId) async {
    final db = await _dbHelper.database;
    await db.delete('reminders', where: 'task_id = ?', whereArgs: [taskId]);
  }

  /// Delete all reminders
  Future<void> deleteAllReminders() async {
    final db = await _dbHelper.database;
    await db.delete('reminders');
  }
}
