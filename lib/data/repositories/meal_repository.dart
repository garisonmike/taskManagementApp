import '../../domain/entities/meal_entity.dart';
import '../datasources/local/meal_local_data_source.dart';
import '../models/meal_model.dart';

/// Repository for meal operations
class MealRepository {
  final MealLocalDataSource _localDataSource;

  MealRepository(this._localDataSource);

  /// Create a new meal
  Future<void> createMeal(MealEntity meal) async {
    final model = MealModel.fromEntity(meal);
    await _localDataSource.createMeal(model);
  }

  /// Get all meals
  Future<List<MealEntity>> getAllMeals() async {
    final models = await _localDataSource.getAllMeals();
    return models.map((model) => model.toEntity()).toList();
  }

  /// Get meals by date range
  Future<List<MealEntity>> getMealsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final models = await _localDataSource.getMealsByDateRange(
      startDate: startDate,
      endDate: endDate,
    );
    return models.map((model) => model.toEntity()).toList();
  }

  /// Get meal by ID
  Future<MealEntity?> getMealById(String id) async {
    final model = await _localDataSource.getMealById(id);
    return model?.toEntity();
  }

  /// Update a meal
  Future<void> updateMeal(MealEntity meal) async {
    final model = MealModel.fromEntity(meal);
    await _localDataSource.updateMeal(model);
  }

  /// Delete a meal
  Future<void> deleteMeal(String id) async {
    await _localDataSource.deleteMeal(id);
  }

  /// Delete all meals
  Future<void> deleteAllMeals() async {
    await _localDataSource.deleteAllMeals();
  }
}
