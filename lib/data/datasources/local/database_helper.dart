import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Database helper for local persistence with schema versioning
/// Implements offline-first storage for the application
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;
  final String? _testPath;

  // Database configuration
  static const String _databaseName = 'task_management.db';
  static const int _databaseVersion = 8;

  DatabaseHelper._internal({String? testPath}) : _testPath = testPath;

  /// Factory constructor for testing with in-memory database
  factory DatabaseHelper.test(String path) {
    return DatabaseHelper._internal(testPath: path);
  }

  /// Get database instance (singleton)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database with proper path
  Future<Database> _initDatabase() async {
    final path = _testPath ?? join(await getDatabasesPath(), _databaseName);

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
        priority TEXT NOT NULL DEFAULT 'normal',
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
        weekday INTEGER,
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

    // Weekly summaries table
    await db.execute('''
      CREATE TABLE weekly_summaries (
        id TEXT PRIMARY KEY,
        week_start_date TEXT NOT NULL,
        week_end_date TEXT NOT NULL,
        total_tasks INTEGER NOT NULL,
        completed_tasks INTEGER NOT NULL,
        failed_tasks INTEGER NOT NULL,
        postponed_tasks INTEGER NOT NULL,
        dropped_tasks INTEGER NOT NULL,
        deleted_tasks INTEGER NOT NULL,
        completion_rate REAL NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Meals table
    await db.execute('''
      CREATE TABLE meals (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        meal_type TEXT NOT NULL,
        consumed_at INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Meal logs table (immutable, optional inclusion in unified logs)
    await db.execute('''
      CREATE TABLE meal_logs (
        id TEXT PRIMARY KEY,
        meal_id TEXT NOT NULL,
        action TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        metadata TEXT
      )
    ''');

    // Meal blueprints table
    await db.execute('''
      CREATE TABLE meal_blueprints (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Blueprint meals table
    await db.execute('''
      CREATE TABLE blueprint_meals (
        id TEXT PRIMARY KEY,
        blueprint_id TEXT NOT NULL,
        day_of_week INTEGER NOT NULL,
        meal_type TEXT NOT NULL,
        meal_name TEXT NOT NULL,
        description TEXT,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (blueprint_id) REFERENCES meal_blueprints (id) ON DELETE CASCADE
      )
    ''');

    // Meal substitutions table
    await db.execute('''
      CREATE TABLE meal_substitutions (
        id TEXT PRIMARY KEY,
        blueprint_id TEXT NOT NULL,
        date INTEGER NOT NULL,
        day_of_week INTEGER NOT NULL,
        meal_type TEXT NOT NULL,
        meal_name TEXT NOT NULL,
        description TEXT,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (blueprint_id) REFERENCES meal_blueprints (id) ON DELETE CASCADE
      )
    ''');

    // Foods table - Excel-like food data with default nutrition columns
    await db.execute('''
      CREATE TABLE foods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        serving_size REAL,
        calories REAL,
        protein REAL,
        carbs REAL,
        fat REAL,
        fiber REAL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Nutrition columns table - Custom user-added columns
    await db.execute('''
      CREATE TABLE nutrition_columns (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        column_type TEXT NOT NULL,
        unit TEXT,
        display_order INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Food nutrition values table - Custom column values for foods
    await db.execute('''
      CREATE TABLE food_nutrition_values (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        food_id INTEGER NOT NULL,
        nutrition_column_id INTEGER NOT NULL,
        value TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (food_id) REFERENCES foods (id) ON DELETE CASCADE,
        FOREIGN KEY (nutrition_column_id) REFERENCES nutrition_columns (id) ON DELETE CASCADE
      )
    ''');

    // App settings table - Application-wide settings
    await db.execute('''
      CREATE TABLE app_settings (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        preset TEXT NOT NULL,
        logs_enabled INTEGER NOT NULL DEFAULT 1,
        graphs_enabled INTEGER NOT NULL DEFAULT 1,
        meals_tracking_enabled INTEGER NOT NULL DEFAULT 1,
        notification_privacy_enabled INTEGER NOT NULL DEFAULT 0,
        task_logs_enabled INTEGER NOT NULL DEFAULT 1,
        meal_logs_enabled INTEGER NOT NULL DEFAULT 1,
        weekly_summaries_enabled INTEGER NOT NULL DEFAULT 1,
        heatmap_visible INTEGER NOT NULL DEFAULT 1,
        updated_at TEXT NOT NULL
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
    await db.execute(
      'CREATE INDEX idx_meals_consumed_at ON meals(consumed_at)',
    );
    await db.execute(
      'CREATE INDEX idx_meal_logs_meal_id ON meal_logs(meal_id)',
    );
    await db.execute(
      'CREATE INDEX idx_meal_logs_timestamp ON meal_logs(timestamp)',
    );
    await db.execute(
      'CREATE INDEX idx_meal_blueprints_active ON meal_blueprints(is_active)',
    );
    await db.execute(
      'CREATE INDEX idx_blueprint_meals_blueprint_id ON blueprint_meals(blueprint_id)',
    );
    await db.execute(
      'CREATE INDEX idx_blueprint_meals_day ON blueprint_meals(day_of_week)',
    );
    await db.execute(
      'CREATE INDEX idx_meal_substitutions_blueprint_id ON meal_substitutions(blueprint_id)',
    );
    await db.execute(
      'CREATE INDEX idx_meal_substitutions_date ON meal_substitutions(date)',
    );
    await db.execute('CREATE INDEX idx_foods_name ON foods(name)');
    await db.execute(
      'CREATE INDEX idx_nutrition_columns_order ON nutrition_columns(display_order)',
    );
    await db.execute(
      'CREATE INDEX idx_food_nutrition_values_food_id ON food_nutrition_values(food_id)',
    );
    await db.execute(
      'CREATE INDEX idx_food_nutrition_values_column_id ON food_nutrition_values(nutrition_column_id)',
    );
  }

  /// Handle database upgrades for future schema versions
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Version 2: Add weekly_summaries table
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE weekly_summaries (
          id TEXT PRIMARY KEY,
          week_start_date TEXT NOT NULL,
          week_end_date TEXT NOT NULL,
          total_tasks INTEGER NOT NULL,
          completed_tasks INTEGER NOT NULL,
          failed_tasks INTEGER NOT NULL,
          postponed_tasks INTEGER NOT NULL,
          dropped_tasks INTEGER NOT NULL,
          deleted_tasks INTEGER NOT NULL,
          completion_rate REAL NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');
    }

    // Version 3: Add meals table
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE meals (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          description TEXT,
          meal_type TEXT NOT NULL,
          consumed_at INTEGER NOT NULL,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');

      await db.execute(
        'CREATE INDEX idx_meals_consumed_at ON meals(consumed_at)',
      );

      await db.execute('''
        CREATE TABLE meal_logs (
          id TEXT PRIMARY KEY,
          meal_id TEXT NOT NULL,
          action TEXT NOT NULL,
          timestamp INTEGER NOT NULL,
          metadata TEXT
        )
      ''');

      await db.execute(
        'CREATE INDEX idx_meal_logs_meal_id ON meal_logs(meal_id)',
      );
      await db.execute(
        'CREATE INDEX idx_meal_logs_timestamp ON meal_logs(timestamp)',
      );
    }

    // Version 4: Add meal blueprint tables
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE meal_blueprints (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          description TEXT,
          is_active INTEGER NOT NULL DEFAULT 1,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE blueprint_meals (
          id TEXT PRIMARY KEY,
          blueprint_id TEXT NOT NULL,
          day_of_week INTEGER NOT NULL,
          meal_type TEXT NOT NULL,
          meal_name TEXT NOT NULL,
          description TEXT,
          created_at INTEGER NOT NULL,
          FOREIGN KEY (blueprint_id) REFERENCES meal_blueprints (id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE meal_substitutions (
          id TEXT PRIMARY KEY,
          blueprint_id TEXT NOT NULL,
          date INTEGER NOT NULL,
          day_of_week INTEGER NOT NULL,
          meal_type TEXT NOT NULL,
          meal_name TEXT NOT NULL,
          description TEXT,
          created_at INTEGER NOT NULL,
          FOREIGN KEY (blueprint_id) REFERENCES meal_blueprints (id) ON DELETE CASCADE
        )
      ''');

      await db.execute(
        'CREATE INDEX idx_meal_blueprints_active ON meal_blueprints(is_active)',
      );
      await db.execute(
        'CREATE INDEX idx_blueprint_meals_blueprint_id ON blueprint_meals(blueprint_id)',
      );
      await db.execute(
        'CREATE INDEX idx_blueprint_meals_day ON blueprint_meals(day_of_week)',
      );
      await db.execute(
        'CREATE INDEX idx_meal_substitutions_blueprint_id ON meal_substitutions(blueprint_id)',
      );
      await db.execute(
        'CREATE INDEX idx_meal_substitutions_date ON meal_substitutions(date)',
      );
    }

    // Version 5: Add foods table
    if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE foods (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT,
          serving_size REAL,
          calories REAL,
          protein REAL,
          carbs REAL,
          fat REAL,
          fiber REAL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE nutrition_columns (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          column_type TEXT NOT NULL,
          unit TEXT,
          display_order INTEGER NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE food_nutrition_values (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          food_id INTEGER NOT NULL,
          nutrition_column_id INTEGER NOT NULL,
          value TEXT NOT NULL,
          created_at TEXT NOT NULL,
          FOREIGN KEY (food_id) REFERENCES foods (id) ON DELETE CASCADE,
          FOREIGN KEY (nutrition_column_id) REFERENCES nutrition_columns (id) ON DELETE CASCADE
        )
      ''');

      await db.execute('CREATE INDEX idx_foods_name ON foods(name)');
      await db.execute(
        'CREATE INDEX idx_nutrition_columns_order ON nutrition_columns(display_order)',
      );
      await db.execute(
        'CREATE INDEX idx_food_nutrition_values_food_id ON food_nutrition_values(food_id)',
      );
      await db.execute(
        'CREATE INDEX idx_food_nutrition_values_column_id ON food_nutrition_values(nutrition_column_id)',
      );
    }

    // Version 6: Add app_settings table
    if (oldVersion < 6) {
      await db.execute('''
        CREATE TABLE app_settings (
          id INTEGER PRIMARY KEY CHECK (id = 1),
          preset TEXT NOT NULL,
          logs_enabled INTEGER NOT NULL DEFAULT 1,
          graphs_enabled INTEGER NOT NULL DEFAULT 1,
          meals_tracking_enabled INTEGER NOT NULL DEFAULT 1,
          notification_privacy_enabled INTEGER NOT NULL DEFAULT 0,
          task_logs_enabled INTEGER NOT NULL DEFAULT 1,
          meal_logs_enabled INTEGER NOT NULL DEFAULT 1,
          weekly_summaries_enabled INTEGER NOT NULL DEFAULT 1,
          heatmap_visible INTEGER NOT NULL DEFAULT 1,
          updated_at TEXT NOT NULL
        )
      ''');
    }

    // Version 7: Add priority column to reminders table
    if (oldVersion < 7) {
      await db.execute('''
        ALTER TABLE reminders ADD COLUMN priority TEXT NOT NULL DEFAULT 'normal'
      ''');
    }

    // Version 8: Add weekday column to blueprint_tasks table
    if (oldVersion < 8) {
      await db.execute('''
        ALTER TABLE blueprint_tasks ADD COLUMN weekday INTEGER
      ''');
    }
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
