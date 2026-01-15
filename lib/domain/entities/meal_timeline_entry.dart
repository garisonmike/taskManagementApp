import 'blueprint_meal_entity.dart';
import 'meal_entity.dart';

/// Source of a timeline entry
enum MealTimelineSource { blueprint, substitution }

/// Timeline entry for weekly meal schedule
class MealTimelineEntry {
  final String blueprintId;
  final String sourceId;
  final DateTime date;
  final DayOfWeek dayOfWeek;
  final MealType mealType;
  final String mealName;
  final String? description;
  final MealTimelineSource source;

  const MealTimelineEntry({
    required this.blueprintId,
    required this.sourceId,
    required this.date,
    required this.dayOfWeek,
    required this.mealType,
    required this.mealName,
    this.description,
    required this.source,
  });
}
