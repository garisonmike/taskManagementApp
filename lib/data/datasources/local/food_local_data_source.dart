import '../../models/food_model.dart';
import 'database_helper.dart';

class FoodLocalDataSource {
  final DatabaseHelper _databaseHelper;

  FoodLocalDataSource(this._databaseHelper);

  Future<int> createFood(FoodModel food) async {
    final db = await _databaseHelper.database;
    return await db.insert('foods', food.toMap());
  }

  Future<FoodModel?> getFoodById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'foods',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return FoodModel.fromMap(maps.first);
  }

  Future<List<FoodModel>> getAllFoods() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'foods',
      orderBy: 'name ASC',
    );

    return maps.map((map) => FoodModel.fromMap(map)).toList();
  }

  Future<List<FoodModel>> searchFoods(String query) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'foods',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'name ASC',
    );

    return maps.map((map) => FoodModel.fromMap(map)).toList();
  }

  Future<int> updateFood(FoodModel food) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'foods',
      food.toMap(),
      where: 'id = ?',
      whereArgs: [food.id],
    );
  }

  Future<int> deleteFood(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete('foods', where: 'id = ?', whereArgs: [id]);
  }
}
