import '../../models/nutrition_column_model.dart';
import 'database_helper.dart';

class NutritionColumnLocalDataSource {
  final DatabaseHelper _databaseHelper;

  NutritionColumnLocalDataSource(this._databaseHelper);

  Future<int> createColumn(NutritionColumnModel column) async {
    final db = await _databaseHelper.database;
    return await db.insert('nutrition_columns', column.toMap());
  }

  Future<NutritionColumnModel?> getColumnById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'nutrition_columns',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return NutritionColumnModel.fromMap(maps.first);
  }

  Future<List<NutritionColumnModel>> getAllColumns() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'nutrition_columns',
      orderBy: 'display_order ASC',
    );

    return maps.map((map) => NutritionColumnModel.fromMap(map)).toList();
  }

  Future<int> updateColumn(NutritionColumnModel column) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'nutrition_columns',
      column.toMap(),
      where: 'id = ?',
      whereArgs: [column.id],
    );
  }

  Future<int> deleteColumn(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'nutrition_columns',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
