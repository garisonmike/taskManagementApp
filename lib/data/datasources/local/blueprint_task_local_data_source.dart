import '../../../domain/entities/blueprint_task_entity.dart';
import '../../models/blueprint_task_model.dart';
import 'database_helper.dart';

/// Local data source for blueprint task CRUD operations
class BlueprintTaskLocalDataSource {
  final DatabaseHelper _dbHelper;

  BlueprintTaskLocalDataSource(this._dbHelper);

  /// Get all tasks for a specific blueprint
  Future<List<BlueprintTaskEntity>> getTasksByBlueprintId(
    String blueprintId,
  ) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'blueprint_tasks',
      where: 'blueprint_id = ?',
      whereArgs: [blueprintId],
      orderBy: 'created_at ASC',
    );
    return maps
        .map((map) => BlueprintTaskModel.fromMap(map).toEntity())
        .toList();
  }

  /// Get blueprint task by ID
  Future<BlueprintTaskEntity?> getBlueprintTaskById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'blueprint_tasks',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return BlueprintTaskModel.fromMap(maps.first).toEntity();
  }

  /// Create a new blueprint task
  Future<void> createBlueprintTask(BlueprintTaskEntity task) async {
    final db = await _dbHelper.database;
    final model = BlueprintTaskModel.fromEntity(task);
    await db.insert('blueprint_tasks', model.toMap());
  }

  /// Update an existing blueprint task
  Future<void> updateBlueprintTask(BlueprintTaskEntity task) async {
    final db = await _dbHelper.database;
    final model = BlueprintTaskModel.fromEntity(task);
    await db.update(
      'blueprint_tasks',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  /// Delete a blueprint task
  Future<void> deleteBlueprintTask(String id) async {
    final db = await _dbHelper.database;
    await db.delete('blueprint_tasks', where: 'id = ?', whereArgs: [id]);
  }

  /// Delete all tasks for a specific blueprint
  Future<void> deleteTasksByBlueprintId(String blueprintId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'blueprint_tasks',
      where: 'blueprint_id = ?',
      whereArgs: [blueprintId],
    );
  }
}
