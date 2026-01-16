import '../../domain/entities/nutrition_column_entity.dart';

class NutritionColumnModel {
  final int? id;
  final String name;
  final String columnType;
  final String? unit;
  final int displayOrder;
  final DateTime createdAt;

  const NutritionColumnModel({
    this.id,
    required this.name,
    required this.columnType,
    this.unit,
    required this.displayOrder,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'column_type': columnType,
      'unit': unit,
      'display_order': displayOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory NutritionColumnModel.fromMap(Map<String, dynamic> map) {
    return NutritionColumnModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      columnType: map['column_type'] as String,
      unit: map['unit'] as String?,
      displayOrder: map['display_order'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  NutritionColumnEntity toEntity() {
    return NutritionColumnEntity(
      id: id,
      name: name,
      columnType: _parseColumnType(columnType),
      unit: unit,
      displayOrder: displayOrder,
      createdAt: createdAt,
    );
  }

  factory NutritionColumnModel.fromEntity(NutritionColumnEntity entity) {
    return NutritionColumnModel(
      id: entity.id,
      name: entity.name,
      columnType: entity.columnType.name,
      unit: entity.unit,
      displayOrder: entity.displayOrder,
      createdAt: entity.createdAt,
    );
  }

  static NutritionColumnType _parseColumnType(String type) {
    switch (type) {
      case 'text':
        return NutritionColumnType.text;
      case 'number':
        return NutritionColumnType.number;
      case 'boolean':
        return NutritionColumnType.boolean;
      default:
        return NutritionColumnType.text;
    }
  }
}
