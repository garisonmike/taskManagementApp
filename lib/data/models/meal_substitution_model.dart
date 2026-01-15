import '../../domain/entities/blueprint_meal_entity.dart';
import '../../domain/entities/meal_entity.dart';
import '../../domain/entities/meal_substitution_entity.dart';

/// Data model for MealSubstitution with database mapping
class MealSubstitutionModel {
  final String id;
  final String blueprintId;
  final int date;
  final int dayOfWeek;
  final String mealType;
  final String mealName;
  final String? description;
  final int createdAt;

  const MealSubstitutionModel({
    required this.id,
    required this.blueprintId,
    required this.date,
    required this.dayOfWeek,
    required this.mealType,
    required this.mealName,
    this.description,
    required this.createdAt,
  });

  factory MealSubstitutionModel.fromEntity(MealSubstitutionEntity entity) {
    return MealSubstitutionModel(
      id: entity.id,
      blueprintId: entity.blueprintId,
      date: _normalizeDate(entity.date).millisecondsSinceEpoch,
      dayOfWeek: entity.dayOfWeek.index + 1,
      mealType: entity.mealType.name,
      mealName: entity.mealName,
      description: entity.description,
      createdAt: entity.createdAt.millisecondsSinceEpoch,
    );
  }

  MealSubstitutionEntity toEntity() {
    return MealSubstitutionEntity(
      id: id,
      blueprintId: blueprintId,
      date: DateTime.fromMillisecondsSinceEpoch(date),
      dayOfWeek: DayOfWeek.values[dayOfWeek - 1],
      mealType: MealType.values.firstWhere(
        (type) => type.name == mealType,
        orElse: () => MealType.snack,
      ),
      mealName: mealName,
      description: description,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
    );
  }

  factory MealSubstitutionModel.fromMap(Map<String, dynamic> map) {
    return MealSubstitutionModel(
      id: map['id'] as String,
      blueprintId: map['blueprint_id'] as String,
      date: map['date'] as int,
      dayOfWeek: map['day_of_week'] as int,
      mealType: map['meal_type'] as String,
      mealName: map['meal_name'] as String,
      description: map['description'] as String?,
      createdAt: map['created_at'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'blueprint_id': blueprintId,
      'date': date,
      'day_of_week': dayOfWeek,
      'meal_type': mealType,
      'meal_name': mealName,
      'description': description,
      'created_at': createdAt,
    };
  }

  static DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
