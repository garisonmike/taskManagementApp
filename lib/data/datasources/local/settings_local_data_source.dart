import 'package:sqflite/sqflite.dart';

import 'database_helper.dart';

/// Local datasource for app settings
/// Demonstrates offline-first data persistence
class SettingsLocalDataSource {
  final DatabaseHelper _dbHelper;

  SettingsLocalDataSource(this._dbHelper);

  /// Save a setting to local database
  Future<void> saveSetting(String key, String value) async {
    final db = await _dbHelper.database;
    await db.insert('settings', {
      'key': key,
      'value': value,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Get a setting from local database
  Future<String?> getSetting(String key) async {
    final db = await _dbHelper.database;
    final results = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (results.isEmpty) return null;
    return results.first['value'] as String;
  }

  /// Get all settings
  Future<Map<String, String>> getAllSettings() async {
    final db = await _dbHelper.database;
    final results = await db.query('settings');

    final settings = <String, String>{};
    for (final row in results) {
      settings[row['key'] as String] = row['value'] as String;
    }
    return settings;
  }

  /// Delete a setting
  Future<void> deleteSetting(String key) async {
    final db = await _dbHelper.database;
    await db.delete('settings', where: 'key = ?', whereArgs: [key]);
  }

  /// Clear all settings
  Future<void> clearAllSettings() async {
    final db = await _dbHelper.database;
    await db.delete('settings');
  }
}
