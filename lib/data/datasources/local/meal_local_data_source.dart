import '../../models/meal_model.dart';
import 'database_helper.dart';

/// Local data source for meals
class MealLocalDataSource {
  final DatabaseHelper _dbHelper;

  MealLocalDataSource(this._dbHelper);

  /// Create a new meal
  Future<void> createMeal(MealModel meal) async {
    final db = await _dbHelper.database;
    await db.insert('meals', meal.toMap());
  }

  /// Get all meals
  Future<List<MealModel>> getAllMeals() async {
    final db = await _dbHelper.database;
    final maps = await db.query('meals', orderBy: 'consumed_at DESC');
    return maps.map((map) => MealModel.fromMap(map)).toList();
  }

  /// Get meals by date range
  Future<List<MealModel>> getMealsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'meals',
      where: 'consumed_at >= ? AND consumed_at <= ?',
      whereArgs: [
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ],
      orderBy: 'consumed_at DESC',
    );
    return maps.map((map) => MealModel.fromMap(map)).toList();
  }

  /// Get meal by ID
  Future<MealModel?> getMealById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'meals',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return MealModel.fromMap(maps.first);
  }

  /// Update a meal
  Future<void> updateMeal(MealModel meal) async {
    final db = await _dbHelper.database;
    await db.update(
      'meals',
      meal.toMap(),
      where: 'id = ?',
      whereArgs: [meal.id],
    );
  }

  /// Delete a meal
  Future<void> deleteMeal(String id) async {
    final db = await _dbHelper.database;
    await db.delete('meals', where: 'id = ?', whereArgs: [id]);
  }

  /// Delete all meals
  Future<void> deleteAllMeals() async {
    final db = await _dbHelper.database;
    await db.delete('meals');
  }
}
