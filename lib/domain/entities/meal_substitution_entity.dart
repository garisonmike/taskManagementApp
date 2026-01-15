import 'blueprint_meal_entity.dart';
import 'meal_entity.dart';

/// Daily meal substitution entity
/// Represents a substitution for a specific date that does not alter the blueprint
class MealSubstitutionEntity {
  final String id;
  final String blueprintId;
  final DateTime date;
  final DayOfWeek dayOfWeek;
  final MealType mealType;
  final String mealName;
  final String? description;
  final DateTime createdAt;

  const MealSubstitutionEntity({
    required this.id,
    required this.blueprintId,
    required this.date,
    required this.dayOfWeek,
    required this.mealType,
    required this.mealName,
    this.description,
    required this.createdAt,
  });

  MealSubstitutionEntity copyWith({
    String? id,
    String? blueprintId,
    DateTime? date,
    DayOfWeek? dayOfWeek,
    MealType? mealType,
    String? mealName,
    String? description,
    DateTime? createdAt,
  }) {
    return MealSubstitutionEntity(
      id: id ?? this.id,
      blueprintId: blueprintId ?? this.blueprintId,
      date: date ?? this.date,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      mealType: mealType ?? this.mealType,
      mealName: mealName ?? this.mealName,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
