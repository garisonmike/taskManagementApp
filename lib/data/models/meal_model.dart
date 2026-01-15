import '../../domain/entities/meal_entity.dart';

/// Data model for Meal persistence
class MealModel {
  final String id;
  final String name;
  final String? description;
  final String mealType;
  final int consumedAt;
  final int createdAt;
  final int updatedAt;

  const MealModel({
    required this.id,
    required this.name,
    this.description,
    required this.mealType,
    required this.consumedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert model to entity
  MealEntity toEntity() {
    return MealEntity(
      id: id,
      name: name,
      description: description,
      mealType: MealType.values.firstWhere(
        (e) => e.name == mealType,
        orElse: () => MealType.snack,
      ),
      consumedAt: DateTime.fromMillisecondsSinceEpoch(consumedAt),
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
    );
  }

  /// Create model from entity
  factory MealModel.fromEntity(MealEntity entity) {
    return MealModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      mealType: entity.mealType.name,
      consumedAt: entity.consumedAt.millisecondsSinceEpoch,
      createdAt: entity.createdAt.millisecondsSinceEpoch,
      updatedAt: entity.updatedAt.millisecondsSinceEpoch,
    );
  }

  /// Create model from database map
  factory MealModel.fromMap(Map<String, dynamic> map) {
    return MealModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      mealType: map['meal_type'] as String,
      consumedAt: map['consumed_at'] as int,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  /// Convert model to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'meal_type': mealType,
      'consumed_at': consumedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
