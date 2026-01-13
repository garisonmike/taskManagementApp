import '../../../domain/entities/task_entity.dart';
import '../../models/task_model.dart';
import '../local/database_helper.dart';

/// Local data source for task operations
class TaskLocalDataSource {
  final DatabaseHelper _databaseHelper;

  TaskLocalDataSource({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  /// Fetch all tasks from database
  Future<List<TaskEntity>> getAllTasks() async {
    final db = await _databaseHelper.database;
    final maps = await db.query('tasks', orderBy: 'created_at DESC');

    return maps.map((map) => TaskModel.fromMap(map).toEntity()).toList();
  }

  /// Get a single task by ID
  Future<TaskEntity?> getTaskById(String id) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return TaskModel.fromMap(maps.first).toEntity();
  }

  /// Insert a new task
  Future<void> insertTask(TaskEntity task) async {
    final db = await _databaseHelper.database;
    final model = TaskModel.fromEntity(task);
    await db.insert('tasks', model.toMap());
  }

  /// Update an existing task
  Future<void> updateTask(TaskEntity task) async {
    final db = await _databaseHelper.database;
    final model = TaskModel.fromEntity(task);
    await db.update(
      'tasks',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  /// Delete a task
  Future<void> deleteTask(String id) async {
    final db = await _databaseHelper.database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  /// Get tasks by completion status
  Future<List<TaskEntity>> getTasksByStatus({required bool isCompleted}) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'tasks',
      where: 'is_completed = ?',
      whereArgs: [isCompleted ? 1 : 0],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => TaskModel.fromMap(map).toEntity()).toList();
  }

  /// Get tasks by type
  Future<List<TaskEntity>> getTasksByType(TaskType type) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'tasks',
      where: 'task_type = ?',
      whereArgs: [type.name],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => TaskModel.fromMap(map).toEntity()).toList();
  }
}
