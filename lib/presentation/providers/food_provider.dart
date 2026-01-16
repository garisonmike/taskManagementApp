import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/database_helper.dart';
import '../../data/datasources/local/food_local_data_source.dart';
import '../../data/datasources/local/food_nutrition_value_local_data_source.dart';
import '../../data/datasources/local/nutrition_column_local_data_source.dart';
import '../../data/repositories/food_repository.dart';
import '../../domain/entities/food_entity.dart';
import '../../domain/entities/food_nutrition_value_entity.dart';
import '../../domain/entities/nutrition_column_entity.dart';

// Data source providers
final foodLocalDataSourceProvider = Provider<FoodLocalDataSource>((ref) {
  return FoodLocalDataSource(DatabaseHelper.instance);
});

final nutritionColumnLocalDataSourceProvider =
    Provider<NutritionColumnLocalDataSource>((ref) {
      return NutritionColumnLocalDataSource(DatabaseHelper.instance);
    });

final foodNutritionValueLocalDataSourceProvider =
    Provider<FoodNutritionValueLocalDataSource>((ref) {
      return FoodNutritionValueLocalDataSource(DatabaseHelper.instance);
    });

// Repository provider
final foodRepositoryProvider = Provider<FoodRepository>((ref) {
  return FoodRepository(
    ref.watch(foodLocalDataSourceProvider),
    ref.watch(nutritionColumnLocalDataSourceProvider),
    ref.watch(foodNutritionValueLocalDataSourceProvider),
  );
});

// Food list provider
final foodsProvider = FutureProvider<List<FoodEntity>>((ref) async {
  final repository = ref.watch(foodRepositoryProvider);
  return await repository.getAllFoods();
});

// Nutrition columns provider
final nutritionColumnsProvider = FutureProvider<List<NutritionColumnEntity>>((
  ref,
) async {
  final repository = ref.watch(foodRepositoryProvider);
  return await repository.getAllColumns();
});

// Food search provider
final foodSearchProvider = FutureProvider.family<List<FoodEntity>, String>((
  ref,
  query,
) async {
  final repository = ref.watch(foodRepositoryProvider);
  return await repository.searchFoods(query);
});

// Food nutrition values by food ID provider
final foodNutritionValuesByFoodProvider =
    FutureProvider.family<List<FoodNutritionValueEntity>, int>((
      ref,
      foodId,
    ) async {
      final repository = ref.watch(foodRepositoryProvider);
      return await repository.getValuesByFoodId(foodId);
    });
