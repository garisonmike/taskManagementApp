import '../../domain/entities/food_nutrition_value_entity.dart';

class FoodNutritionValueModel {
  final int? id;
  final int foodId;
  final int nutritionColumnId;
  final String value;
  final DateTime createdAt;

  const FoodNutritionValueModel({
    this.id,
    required this.foodId,
    required this.nutritionColumnId,
    required this.value,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'food_id': foodId,
      'nutrition_column_id': nutritionColumnId,
      'value': value,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory FoodNutritionValueModel.fromMap(Map<String, dynamic> map) {
    return FoodNutritionValueModel(
      id: map['id'] as int?,
      foodId: map['food_id'] as int,
      nutritionColumnId: map['nutrition_column_id'] as int,
      value: map['value'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  FoodNutritionValueEntity toEntity() {
    return FoodNutritionValueEntity(
      id: id,
      foodId: foodId,
      nutritionColumnId: nutritionColumnId,
      value: value,
      createdAt: createdAt,
    );
  }

  factory FoodNutritionValueModel.fromEntity(FoodNutritionValueEntity entity) {
    return FoodNutritionValueModel(
      id: entity.id,
      foodId: entity.foodId,
      nutritionColumnId: entity.nutritionColumnId,
      value: entity.value,
      createdAt: entity.createdAt,
    );
  }
}
