import 'meal_entity.dart';

/// Blueprint meal entry entity
/// Represents a meal slot in a weekly blueprint
class BlueprintMealEntity {
  final String id;
  final String blueprintId;
  final DayOfWeek dayOfWeek;
  final MealType mealType;
  final String mealName;
  final String? description;
  final DateTime createdAt;

  const BlueprintMealEntity({
    required this.id,
    required this.blueprintId,
    required this.dayOfWeek,
    required this.mealType,
    required this.mealName,
    this.description,
    required this.createdAt,
  });

  BlueprintMealEntity copyWith({
    String? id,
    String? blueprintId,
    DayOfWeek? dayOfWeek,
    MealType? mealType,
    String? mealName,
    String? description,
    DateTime? createdAt,
  }) {
    return BlueprintMealEntity(
      id: id ?? this.id,
      blueprintId: blueprintId ?? this.blueprintId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      mealType: mealType ?? this.mealType,
      mealName: mealName ?? this.mealName,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Days of the week
enum DayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday;

  String get displayName {
    switch (this) {
      case DayOfWeek.monday:
        return 'Monday';
      case DayOfWeek.tuesday:
        return 'Tuesday';
      case DayOfWeek.wednesday:
        return 'Wednesday';
      case DayOfWeek.thursday:
        return 'Thursday';
      case DayOfWeek.friday:
        return 'Friday';
      case DayOfWeek.saturday:
        return 'Saturday';
      case DayOfWeek.sunday:
        return 'Sunday';
    }
  }

  /// Get DayOfWeek from DateTime weekday (1-7)
  static DayOfWeek fromDateTime(DateTime date) {
    return DayOfWeek.values[date.weekday - 1];
  }
}
