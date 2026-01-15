import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/database_helper.dart';
import '../../data/datasources/local/meal_local_data_source.dart';
import '../../data/repositories/meal_repository.dart';
import '../../domain/entities/meal_entity.dart';

/// Provider for meal local data source
final mealLocalDataSourceProvider = Provider<MealLocalDataSource>((ref) {
  final dbHelper = DatabaseHelper.instance;
  return MealLocalDataSource(dbHelper);
});

/// Provider for meal repository
final mealRepositoryProvider = Provider<MealRepository>((ref) {
  final dataSource = ref.watch(mealLocalDataSourceProvider);
  return MealRepository(dataSource);
});

/// Provider for meals list
final mealsProvider = FutureProvider<List<MealEntity>>((ref) async {
  final repository = ref.watch(mealRepositoryProvider);
  return await repository.getAllMeals();
});

/// Provider for meals by date range
final mealsByDateRangeProvider =
    FutureProvider.family<
      List<MealEntity>,
      ({DateTime startDate, DateTime endDate})
    >((ref, params) async {
      final repository = ref.watch(mealRepositoryProvider);
      return await repository.getMealsByDateRange(
        startDate: params.startDate,
        endDate: params.endDate,
      );
    });
