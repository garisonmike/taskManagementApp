import '../../domain/entities/food_entity.dart';

class FoodModel {
  final int? id;
  final String name;
  final String? description;
  final double? servingSize;
  final double? calories;
  final double? protein;
  final double? carbs;
  final double? fat;
  final double? fiber;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FoodModel({
    this.id,
    required this.name,
    this.description,
    this.servingSize,
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
    this.fiber,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'serving_size': servingSize,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory FoodModel.fromMap(Map<String, dynamic> map) {
    return FoodModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      servingSize: map['serving_size'] as double?,
      calories: map['calories'] as double?,
      protein: map['protein'] as double?,
      carbs: map['carbs'] as double?,
      fat: map['fat'] as double?,
      fiber: map['fiber'] as double?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  FoodEntity toEntity() {
    return FoodEntity(
      id: id,
      name: name,
      description: description,
      servingSize: servingSize,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      fiber: fiber,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory FoodModel.fromEntity(FoodEntity entity) {
    return FoodModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      servingSize: entity.servingSize,
      calories: entity.calories,
      protein: entity.protein,
      carbs: entity.carbs,
      fat: entity.fat,
      fiber: entity.fiber,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
