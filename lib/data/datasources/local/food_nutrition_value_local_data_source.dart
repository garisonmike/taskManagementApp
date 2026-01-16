import '../../models/food_nutrition_value_model.dart';
import 'database_helper.dart';

class FoodNutritionValueLocalDataSource {
  final DatabaseHelper _databaseHelper;

  FoodNutritionValueLocalDataSource(this._databaseHelper);

  Future<int> createValue(FoodNutritionValueModel value) async {
    final db = await _databaseHelper.database;
    return await db.insert('food_nutrition_values', value.toMap());
  }

  Future<FoodNutritionValueModel?> getValueById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'food_nutrition_values',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return FoodNutritionValueModel.fromMap(maps.first);
  }

  Future<List<FoodNutritionValueModel>> getValuesByFoodId(int foodId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'food_nutrition_values',
      where: 'food_id = ?',
      whereArgs: [foodId],
    );

    return maps.map((map) => FoodNutritionValueModel.fromMap(map)).toList();
  }

  Future<List<FoodNutritionValueModel>> getValuesByColumnId(
    int columnId,
  ) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'food_nutrition_values',
      where: 'nutrition_column_id = ?',
      whereArgs: [columnId],
    );

    return maps.map((map) => FoodNutritionValueModel.fromMap(map)).toList();
  }

  Future<int> updateValue(FoodNutritionValueModel value) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'food_nutrition_values',
      value.toMap(),
      where: 'id = ?',
      whereArgs: [value.id],
    );
  }

  Future<int> deleteValue(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'food_nutrition_values',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteValuesByFoodId(int foodId) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'food_nutrition_values',
      where: 'food_id = ?',
      whereArgs: [foodId],
    );
  }

  Future<int> deleteValuesByColumnId(int columnId) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'food_nutrition_values',
      where: 'nutrition_column_id = ?',
      whereArgs: [columnId],
    );
  }
}
