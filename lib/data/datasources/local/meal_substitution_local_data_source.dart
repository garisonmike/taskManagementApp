import '../../../domain/entities/meal_substitution_entity.dart';
import '../../models/meal_substitution_model.dart';
import 'database_helper.dart';

/// Local data source for meal substitution operations
class MealSubstitutionLocalDataSource {
  final DatabaseHelper _dbHelper;

  MealSubstitutionLocalDataSource(this._dbHelper);

  /// Get substitutions for a blueprint within a date range
  Future<List<MealSubstitutionEntity>> getSubstitutionsByDateRange({
    required String blueprintId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await _dbHelper.database;
    final start = _normalizeDate(startDate).millisecondsSinceEpoch;
    final end = _normalizeDate(endDate).millisecondsSinceEpoch;
    final maps = await db.query(
      'meal_substitutions',
      where: 'blueprint_id = ? AND date >= ? AND date <= ?',
      whereArgs: [blueprintId, start, end],
      orderBy: 'date ASC, meal_type ASC',
    );
    return maps
        .map((map) => MealSubstitutionModel.fromMap(map).toEntity())
        .toList();
  }

  /// Get substitution by ID
  Future<MealSubstitutionEntity?> getSubstitutionById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'meal_substitutions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return MealSubstitutionModel.fromMap(maps.first).toEntity();
  }

  /// Create a new substitution
  Future<void> createSubstitution(MealSubstitutionEntity substitution) async {
    final db = await _dbHelper.database;
    final model = MealSubstitutionModel.fromEntity(substitution);
    await db.insert('meal_substitutions', model.toMap());
  }

  /// Delete a substitution
  Future<void> deleteSubstitution(String id) async {
    final db = await _dbHelper.database;
    await db.delete('meal_substitutions', where: 'id = ?', whereArgs: [id]);
  }

  /// Delete all substitutions for a blueprint
  Future<void> deleteSubstitutionsByBlueprintId(String blueprintId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'meal_substitutions',
      where: 'blueprint_id = ?',
      whereArgs: [blueprintId],
    );
  }

  static DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
