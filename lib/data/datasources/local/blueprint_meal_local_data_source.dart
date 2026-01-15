import '../../../domain/entities/blueprint_meal_entity.dart';
import '../../models/blueprint_meal_model.dart';
import 'database_helper.dart';

/// Local data source for blueprint meal CRUD operations
class BlueprintMealLocalDataSource {
  final DatabaseHelper _dbHelper;

  BlueprintMealLocalDataSource(this._dbHelper);

  /// Get all meals for a specific blueprint
  Future<List<BlueprintMealEntity>> getMealsByBlueprintId(
    String blueprintId,
  ) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'blueprint_meals',
      where: 'blueprint_id = ?',
      whereArgs: [blueprintId],
      orderBy: 'day_of_week ASC, meal_type ASC',
    );
    return maps
        .map((map) => BlueprintMealModel.fromMap(map).toEntity())
        .toList();
  }

  /// Get blueprint meal by ID
  Future<BlueprintMealEntity?> getMealById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'blueprint_meals',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return BlueprintMealModel.fromMap(maps.first).toEntity();
  }

  /// Create a new blueprint meal
  Future<void> createBlueprintMeal(BlueprintMealEntity meal) async {
    final db = await _dbHelper.database;
    final model = BlueprintMealModel.fromEntity(meal);
    await db.insert('blueprint_meals', model.toMap());
  }

  /// Update an existing blueprint meal
  Future<void> updateBlueprintMeal(BlueprintMealEntity meal) async {
    final db = await _dbHelper.database;
    final model = BlueprintMealModel.fromEntity(meal);
    await db.update(
      'blueprint_meals',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [meal.id],
    );
  }

  /// Delete a blueprint meal
  Future<void> deleteBlueprintMeal(String id) async {
    final db = await _dbHelper.database;
    await db.delete('blueprint_meals', where: 'id = ?', whereArgs: [id]);
  }

  /// Delete all meals for a specific blueprint
  Future<void> deleteMealsByBlueprintId(String blueprintId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'blueprint_meals',
      where: 'blueprint_id = ?',
      whereArgs: [blueprintId],
    );
  }
}
