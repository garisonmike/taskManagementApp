import 'package:sqflite/sqflite.dart';

import '../../../domain/entities/app_settings_entity.dart';
import '../../models/app_settings_model.dart';
import 'database_helper.dart';

class AppSettingsLocalDataSource {
  final DatabaseHelper _databaseHelper;

  AppSettingsLocalDataSource(this._databaseHelper);

  /// Get settings (singleton row with id = 1)
  Future<AppSettingsModel?> getSettings() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'app_settings',
      where: 'id = ?',
      whereArgs: [1],
    );

    if (maps.isEmpty) return null;
    return AppSettingsModel.fromMap(maps.first);
  }

  /// Create or update settings (upsert)
  Future<int> saveSettings(AppSettingsModel settings) async {
    final db = await _databaseHelper.database;
    final map = settings.toMap();
    map['id'] = 1; // Force singleton pattern

    return await db.insert(
      'app_settings',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Initialize with default settings if not exists
  Future<void> initializeDefaultSettings() async {
    final existing = await getSettings();
    if (existing == null) {
      final defaultSettings = AppSettingsModel.fromEntity(
        AppSettingsEntity.defaultSimple(),
      );
      await saveSettings(defaultSettings);
    }
  }
}
