import '../../../domain/entities/blueprint_entity.dart';
import '../../models/blueprint_model.dart';
import 'database_helper.dart';

/// Local data source for blueprint CRUD operations
class BlueprintLocalDataSource {
  final DatabaseHelper _dbHelper;

  BlueprintLocalDataSource(this._dbHelper);

  /// Get all blueprints
  Future<List<BlueprintEntity>> getAllBlueprints() async {
    final db = await _dbHelper.database;
    final maps = await db.query('blueprints', orderBy: 'created_at DESC');
    return maps.map((map) => BlueprintModel.fromMap(map).toEntity()).toList();
  }

  /// Get active blueprints only
  Future<List<BlueprintEntity>> getActiveBlueprints() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'blueprints',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => BlueprintModel.fromMap(map).toEntity()).toList();
  }

  /// Get blueprint by ID
  Future<BlueprintEntity?> getBlueprintById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'blueprints',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return BlueprintModel.fromMap(maps.first).toEntity();
  }

  /// Create a new blueprint
  Future<void> createBlueprint(BlueprintEntity blueprint) async {
    final db = await _dbHelper.database;
    final model = BlueprintModel.fromEntity(blueprint);
    await db.insert('blueprints', model.toMap());
  }

  /// Update an existing blueprint
  Future<void> updateBlueprint(BlueprintEntity blueprint) async {
    final db = await _dbHelper.database;
    final model = BlueprintModel.fromEntity(blueprint);
    await db.update(
      'blueprints',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [blueprint.id],
    );
  }

  /// Delete a blueprint
  Future<void> deleteBlueprint(String id) async {
    final db = await _dbHelper.database;
    await db.delete('blueprints', where: 'id = ?', whereArgs: [id]);
  }
}
