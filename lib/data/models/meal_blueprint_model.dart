import '../../domain/entities/meal_blueprint_entity.dart';

/// Data model for MealBlueprint with database mapping
class MealBlueprintModel {
  final String id;
  final String name;
  final String? description;
  final int isActive;
  final int createdAt;
  final int updatedAt;

  const MealBlueprintModel({
    required this.id,
    required this.name,
    this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MealBlueprintModel.fromEntity(MealBlueprintEntity entity) {
    return MealBlueprintModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      isActive: entity.isActive ? 1 : 0,
      createdAt: entity.createdAt.millisecondsSinceEpoch,
      updatedAt: entity.updatedAt.millisecondsSinceEpoch,
    );
  }

  MealBlueprintEntity toEntity() {
    return MealBlueprintEntity(
      id: id,
      name: name,
      description: description,
      isActive: isActive == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
    );
  }

  factory MealBlueprintModel.fromMap(Map<String, dynamic> map) {
    return MealBlueprintModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      isActive: map['is_active'] as int,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
