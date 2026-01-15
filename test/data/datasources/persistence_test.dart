import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:task_management_app/data/datasources/local/database_helper.dart';
import 'package:task_management_app/data/datasources/local/settings_local_data_source.dart';

void main() {
  late DatabaseHelper dbHelper;
  late SettingsLocalDataSource dataSource;

  // Initialize FFI for testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });
  setUp(() async {
    dbHelper = DatabaseHelper.instance;
    dataSource = SettingsLocalDataSource(dbHelper);

    // Clean database before each test
    await dbHelper.deleteDb();
  });

  tearDown(() async {
    await dbHelper.close();
  });

  group('Local Persistence Tests', () {
    test('Database initializes successfully', () async {
      final db = await dbHelper.database;
      expect(db.isOpen, true);
    });

    test(
      'Data persists across database reopens (simulating app restart)',
      () async {
        // Save data
        await dataSource.saveSetting('test_key', 'test_value');

        // Close database (simulating app close)
        await dbHelper.close();

        // Reopen database (simulating app restart)
        final value = await dataSource.getSetting('test_key');

        // Verify data persisted
        expect(value, 'test_value');
      },
    );

    test('Multiple settings persist correctly', () async {
      // Save multiple settings
      await dataSource.saveSetting('theme', 'timber_brown');
      await dataSource.saveSetting('notifications_enabled', 'true');
      await dataSource.saveSetting('user_name', 'Test User');

      // Close and reopen
      await dbHelper.close();

      // Verify all data persisted
      final allSettings = await dataSource.getAllSettings();
      expect(allSettings['theme'], 'timber_brown');
      expect(allSettings['notifications_enabled'], 'true');
      expect(allSettings['user_name'], 'Test User');
    });

    test('Schema version is maintained', () async {
      final db = await dbHelper.database;
      // Query version from PRAGMA
      final result = await db.rawQuery('PRAGMA user_version');
      final version = result.first['user_version'] as int;
      expect(version, 2);
    });

    test('All required tables are created', () async {
      final db = await dbHelper.database;

      // Query sqlite_master to check tables exist
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
      );

      final tableNames = tables.map((t) => t['name'] as String).toSet();

      expect(tableNames.contains('tasks'), true);
      expect(tableNames.contains('reminders'), true);
      expect(tableNames.contains('blueprints'), true);
      expect(tableNames.contains('blueprint_tasks'), true);
      expect(tableNames.contains('task_logs'), true);
      expect(tableNames.contains('settings'), true);
    });

    test('Indexes are created for performance', () async {
      final db = await dbHelper.database;

      final indexes = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND name NOT LIKE 'sqlite_%'",
      );

      final indexNames = indexes.map((i) => i['name'] as String).toSet();

      expect(indexNames.contains('idx_tasks_deadline'), true);
      expect(indexNames.contains('idx_tasks_created_at'), true);
      expect(indexNames.contains('idx_reminders_task_id'), true);
      expect(indexNames.contains('idx_task_logs_task_id'), true);
      expect(indexNames.contains('idx_task_logs_timestamp'), true);
    });
  });
}
