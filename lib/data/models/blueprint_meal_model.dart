import '../../domain/entities/blueprint_meal_entity.dart';
import '../../domain/entities/meal_entity.dart';

/// Data model for BlueprintMeal with database mapping
class BlueprintMealModel {
  final String id;
  final String blueprintId;
  final int dayOfWeek;
  final String mealType;
  final String mealName;
  final String? description;
  final int createdAt;

  const BlueprintMealModel({
    required this.id,
    required this.blueprintId,
    required this.dayOfWeek,
    required this.mealType,
    required this.mealName,
    this.description,
    required this.createdAt,
  });

  factory BlueprintMealModel.fromEntity(BlueprintMealEntity entity) {
    return BlueprintMealModel(
      id: entity.id,
      blueprintId: entity.blueprintId,
      dayOfWeek: entity.dayOfWeek.index + 1,
      mealType: entity.mealType.name,
      mealName: entity.mealName,
      description: entity.description,
      createdAt: entity.createdAt.millisecondsSinceEpoch,
    );
  }

  BlueprintMealEntity toEntity() {
    return BlueprintMealEntity(
      id: id,
      blueprintId: blueprintId,
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

  factory BlueprintMealModel.fromMap(Map<String, dynamic> map) {
    return BlueprintMealModel(
      id: map['id'] as String,
      blueprintId: map['blueprint_id'] as String,
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
      'day_of_week': dayOfWeek,
      'meal_type': mealType,
      'meal_name': mealName,
      'description': description,
      'created_at': createdAt,
    };
  }
}
