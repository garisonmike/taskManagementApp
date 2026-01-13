import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Database helper for local persistence with schema versioning
/// Implements offline-first storage for the application
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  // Database configuration
  static const String _databaseName = 'task_management.db';
  static const int _databaseVersion = 1;

  DatabaseHelper._internal();

  /// Get database instance (singleton)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database with proper path
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create database schema (version 1)
  Future<void> _onCreate(Database db, int version) async {
    // Tasks table - Core task management
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        task_type TEXT NOT NULL,
        deadline INTEGER,
        time_based_start INTEGER,
        time_based_end INTEGER,
        is_completed INTEGER NOT NULL DEFAULT 0,
        completion_date INTEGER,
        failure_reason TEXT,
        is_postponed INTEGER NOT NULL DEFAULT 0,
        is_dropped INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Reminders table
    await db.execute('''
      CREATE TABLE reminders (
        id TEXT PRIMARY KEY,
        task_id TEXT NOT NULL,
        reminder_time INTEGER NOT NULL,
        is_enabled INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE
      )
    ''');

    // Blueprints table - For recurring task templates
    await db.execute('''
      CREATE TABLE blueprints (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Blueprint tasks table
    await db.execute('''
      CREATE TABLE blueprint_tasks (
        id TEXT PRIMARY KEY,
        blueprint_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        task_type TEXT NOT NULL,
        default_time TEXT,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (blueprint_id) REFERENCES blueprints (id) ON DELETE CASCADE
      )
    ''');

    // Task logs table (immutable)
    await db.execute('''
      CREATE TABLE task_logs (
        id TEXT PRIMARY KEY,
        task_id TEXT NOT NULL,
        action TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        metadata TEXT
      )
    ''');

    // Settings table
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Create indexes for better query performance
    await db.execute('CREATE INDEX idx_tasks_deadline ON tasks(deadline)');
    await db.execute('CREATE INDEX idx_tasks_created_at ON tasks(created_at)');
    await db.execute(
      'CREATE INDEX idx_reminders_task_id ON reminders(task_id)',
    );
    await db.execute(
      'CREATE INDEX idx_task_logs_task_id ON task_logs(task_id)',
    );
    await db.execute(
      'CREATE INDEX idx_task_logs_timestamp ON task_logs(timestamp)',
    );
  }

  /// Handle database upgrades for future schema versions
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Version 2 migrations will go here
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE tasks ADD COLUMN new_field TEXT');
    // }

    // Version 3 migrations will go here
    // if (oldVersion < 3) {
    //   await db.execute('CREATE TABLE new_table (...)');
    // }
  }

  /// Close database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Delete database (useful for testing)
  Future<void> deleteDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);
    await deleteDatabase(path);
    _database = null;
  }
}
