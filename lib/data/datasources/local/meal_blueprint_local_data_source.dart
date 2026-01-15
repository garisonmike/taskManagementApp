import '../../../domain/entities/meal_blueprint_entity.dart';
import '../../models/meal_blueprint_model.dart';
import 'database_helper.dart';

/// Local data source for meal blueprint CRUD operations
class MealBlueprintLocalDataSource {
  final DatabaseHelper _dbHelper;

  MealBlueprintLocalDataSource(this._dbHelper);

  /// Get all meal blueprints
  Future<List<MealBlueprintEntity>> getAllBlueprints() async {
    final db = await _dbHelper.database;
    final maps = await db.query('meal_blueprints', orderBy: 'created_at DESC');
    return maps
        .map((map) => MealBlueprintModel.fromMap(map).toEntity())
        .toList();
  }

  /// Get active meal blueprints only
  Future<List<MealBlueprintEntity>> getActiveBlueprints() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'meal_blueprints',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'created_at DESC',
    );
    return maps
        .map((map) => MealBlueprintModel.fromMap(map).toEntity())
        .toList();
  }

  /// Get meal blueprint by ID
  Future<MealBlueprintEntity?> getBlueprintById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'meal_blueprints',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return MealBlueprintModel.fromMap(maps.first).toEntity();
  }

  /// Create a new meal blueprint
  Future<void> createBlueprint(MealBlueprintEntity blueprint) async {
    final db = await _dbHelper.database;
    final model = MealBlueprintModel.fromEntity(blueprint);
    await db.insert('meal_blueprints', model.toMap());
  }

  /// Update an existing meal blueprint
  Future<void> updateBlueprint(MealBlueprintEntity blueprint) async {
    final db = await _dbHelper.database;
    final model = MealBlueprintModel.fromEntity(blueprint);
    await db.update(
      'meal_blueprints',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [blueprint.id],
    );
  }

  /// Delete a meal blueprint
  Future<void> deleteBlueprint(String id) async {
    final db = await _dbHelper.database;
    await db.delete('meal_blueprints', where: 'id = ?', whereArgs: [id]);
  }
}
