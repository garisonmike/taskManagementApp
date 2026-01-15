import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/meal_blueprint_service.dart';
import '../../data/datasources/local/blueprint_meal_local_data_source.dart';
import '../../data/datasources/local/database_helper.dart';
import '../../data/datasources/local/meal_blueprint_local_data_source.dart';
import '../../data/datasources/local/meal_substitution_local_data_source.dart';
import '../../data/repositories/meal_blueprint_repository.dart';
import '../../domain/entities/meal_blueprint_entity.dart';
import '../../domain/entities/meal_timeline_entry.dart';

/// Provider for DatabaseHelper
final mealDatabaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

/// Provider for MealBlueprintLocalDataSource
final mealBlueprintLocalDataSourceProvider =
    Provider<MealBlueprintLocalDataSource>((ref) {
      return MealBlueprintLocalDataSource(
        ref.watch(mealDatabaseHelperProvider),
      );
    });

/// Provider for BlueprintMealLocalDataSource
final blueprintMealLocalDataSourceProvider =
    Provider<BlueprintMealLocalDataSource>((ref) {
      return BlueprintMealLocalDataSource(
        ref.watch(mealDatabaseHelperProvider),
      );
    });

/// Provider for MealSubstitutionLocalDataSource
final mealSubstitutionLocalDataSourceProvider =
    Provider<MealSubstitutionLocalDataSource>((ref) {
      return MealSubstitutionLocalDataSource(
        ref.watch(mealDatabaseHelperProvider),
      );
    });

/// Provider for MealBlueprintRepository
final mealBlueprintRepositoryProvider = Provider<MealBlueprintRepository>((
  ref,
) {
  return MealBlueprintRepository(
    ref.watch(mealBlueprintLocalDataSourceProvider),
    ref.watch(blueprintMealLocalDataSourceProvider),
    ref.watch(mealSubstitutionLocalDataSourceProvider),
  );
});

/// Provider for MealBlueprintService
final mealBlueprintServiceProvider = Provider<MealBlueprintService>((ref) {
  return MealBlueprintService(ref.watch(mealBlueprintRepositoryProvider));
});

/// Provider for all meal blueprints
final mealBlueprintsProvider = FutureProvider<List<MealBlueprintEntity>>((ref) {
  final repository = ref.watch(mealBlueprintRepositoryProvider);
  return repository.getAllBlueprints();
});

/// Provider for active meal blueprints
final activeMealBlueprintsProvider = FutureProvider<List<MealBlueprintEntity>>((
  ref,
) {
  final repository = ref.watch(mealBlueprintRepositoryProvider);
  return repository.getActiveBlueprints();
});

/// Provider for weekly timeline
final weeklyMealTimelineProvider =
    FutureProvider.family<
      List<MealTimelineEntry>,
      ({String blueprintId, DateTime weekStart})
    >((ref, params) async {
      final service = ref.watch(mealBlueprintServiceProvider);
      return service.getWeeklyTimeline(
        blueprintId: params.blueprintId,
        weekStart: params.weekStart,
      );
    });
