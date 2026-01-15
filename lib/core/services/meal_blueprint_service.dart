import '../../data/repositories/meal_blueprint_repository.dart';
import '../../domain/entities/blueprint_meal_entity.dart';
import '../../domain/entities/meal_entity.dart';
import '../../domain/entities/meal_substitution_entity.dart';
import '../../domain/entities/meal_timeline_entry.dart';

/// Service for building weekly meal timelines from blueprints
class MealBlueprintService {
  final MealBlueprintRepository _repository;

  MealBlueprintService(this._repository);

  /// Build a weekly timeline for a blueprint
  Future<List<MealTimelineEntry>> getWeeklyTimeline({
    required String blueprintId,
    required DateTime weekStart,
  }) async {
    final start = _startOfWeek(weekStart);
    final end = start.add(const Duration(days: 6));

    final blueprintMeals = await _repository.getMealsByBlueprintId(blueprintId);
    final substitutions = await _repository.getSubstitutionsByDateRange(
      blueprintId: blueprintId,
      startDate: start,
      endDate: end,
    );

    final blueprintMap = _buildBlueprintMap(blueprintMeals);
    final substitutionMap = _buildSubstitutionMap(substitutions);

    final entries = <MealTimelineEntry>[];
    for (var i = 0; i < 7; i++) {
      final date = start.add(Duration(days: i));
      final dayOfWeek = DayOfWeek.fromDateTime(date);
      for (final mealType in MealType.values) {
        final substitutionKey = _subKey(date, mealType);
        final substitution = substitutionMap[substitutionKey];
        if (substitution != null) {
          entries.add(
            MealTimelineEntry(
              blueprintId: blueprintId,
              sourceId: substitution.id,
              date: date,
              dayOfWeek: substitution.dayOfWeek,
              mealType: substitution.mealType,
              mealName: substitution.mealName,
              description: substitution.description,
              source: MealTimelineSource.substitution,
            ),
          );
          continue;
        }

        final blueprintKey = _blueprintKey(dayOfWeek, mealType);
        final blueprintMeal = blueprintMap[blueprintKey];
        if (blueprintMeal != null) {
          entries.add(
            MealTimelineEntry(
              blueprintId: blueprintId,
              sourceId: blueprintMeal.id,
              date: date,
              dayOfWeek: blueprintMeal.dayOfWeek,
              mealType: blueprintMeal.mealType,
              mealName: blueprintMeal.mealName,
              description: blueprintMeal.description,
              source: MealTimelineSource.blueprint,
            ),
          );
        }
      }
    }

    return entries;
  }

  static DateTime _startOfWeek(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return normalized.subtract(Duration(days: normalized.weekday - 1));
  }

  static Map<String, BlueprintMealEntity> _buildBlueprintMap(
    List<BlueprintMealEntity> meals,
  ) {
    final map = <String, BlueprintMealEntity>{};
    for (final meal in meals) {
      map[_blueprintKey(meal.dayOfWeek, meal.mealType)] = meal;
    }
    return map;
  }

  static Map<String, MealSubstitutionEntity> _buildSubstitutionMap(
    List<MealSubstitutionEntity> substitutions,
  ) {
    final map = <String, MealSubstitutionEntity>{};
    for (final substitution in substitutions) {
      map[_subKey(substitution.date, substitution.mealType)] = substitution;
    }
    return map;
  }

  static String _blueprintKey(DayOfWeek dayOfWeek, MealType mealType) {
    return '${dayOfWeek.name}_${mealType.name}';
  }

  static String _subKey(DateTime date, MealType mealType) {
    final normalized = DateTime(date.year, date.month, date.day);
    return '${normalized.toIso8601String()}_${mealType.name}';
  }
}
