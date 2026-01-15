import '../../domain/entities/blueprint_meal_entity.dart';
import '../../domain/entities/meal_blueprint_entity.dart';
import '../../domain/entities/meal_substitution_entity.dart';
import '../datasources/local/blueprint_meal_local_data_source.dart';
import '../datasources/local/meal_blueprint_local_data_source.dart';
import '../datasources/local/meal_substitution_local_data_source.dart';

/// Repository for meal blueprint operations
class MealBlueprintRepository {
  final MealBlueprintLocalDataSource _blueprintDataSource;
  final BlueprintMealLocalDataSource _blueprintMealDataSource;
  final MealSubstitutionLocalDataSource _substitutionDataSource;

  MealBlueprintRepository(
    this._blueprintDataSource,
    this._blueprintMealDataSource,
    this._substitutionDataSource,
  );

  Future<List<MealBlueprintEntity>> getAllBlueprints() async {
    return await _blueprintDataSource.getAllBlueprints();
  }

  Future<List<MealBlueprintEntity>> getActiveBlueprints() async {
    return await _blueprintDataSource.getActiveBlueprints();
  }

  Future<MealBlueprintEntity?> getBlueprintById(String id) async {
    return await _blueprintDataSource.getBlueprintById(id);
  }

  Future<void> createBlueprint(MealBlueprintEntity blueprint) async {
    await _blueprintDataSource.createBlueprint(blueprint);
  }

  Future<void> updateBlueprint(MealBlueprintEntity blueprint) async {
    final updated = blueprint.copyWith(updatedAt: DateTime.now());
    await _blueprintDataSource.updateBlueprint(updated);
  }

  Future<void> deleteBlueprint(String id) async {
    await _blueprintMealDataSource.deleteMealsByBlueprintId(id);
    await _substitutionDataSource.deleteSubstitutionsByBlueprintId(id);
    await _blueprintDataSource.deleteBlueprint(id);
  }

  Future<List<BlueprintMealEntity>> getMealsByBlueprintId(
    String blueprintId,
  ) async {
    return await _blueprintMealDataSource.getMealsByBlueprintId(blueprintId);
  }

  Future<BlueprintMealEntity?> getBlueprintMealById(String id) async {
    return await _blueprintMealDataSource.getMealById(id);
  }

  Future<void> createBlueprintMeal(BlueprintMealEntity meal) async {
    await _blueprintMealDataSource.createBlueprintMeal(meal);
  }

  Future<void> updateBlueprintMeal(BlueprintMealEntity meal) async {
    await _blueprintMealDataSource.updateBlueprintMeal(meal);
  }

  Future<void> deleteBlueprintMeal(String id) async {
    await _blueprintMealDataSource.deleteBlueprintMeal(id);
  }

  Future<List<MealSubstitutionEntity>> getSubstitutionsByDateRange({
    required String blueprintId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await _substitutionDataSource.getSubstitutionsByDateRange(
      blueprintId: blueprintId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<MealSubstitutionEntity?> getSubstitutionById(String id) async {
    return await _substitutionDataSource.getSubstitutionById(id);
  }

  Future<void> createSubstitution(MealSubstitutionEntity substitution) async {
    await _substitutionDataSource.createSubstitution(substitution);
  }

  Future<void> deleteSubstitution(String id) async {
    await _substitutionDataSource.deleteSubstitution(id);
  }
}
