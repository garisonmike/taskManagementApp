enum NutritionColumnType {
  text,
  number,
  boolean;

  String get displayName {
    switch (this) {
      case NutritionColumnType.text:
        return 'Text';
      case NutritionColumnType.number:
        return 'Number';
      case NutritionColumnType.boolean:
        return 'Boolean';
    }
  }
}

class NutritionColumnEntity {
  final int? id;
  final String name;
  final NutritionColumnType columnType;
  final String? unit; // e.g., "mg", "mcg", "%"
  final int displayOrder;
  final DateTime createdAt;

  const NutritionColumnEntity({
    this.id,
    required this.name,
    required this.columnType,
    this.unit,
    required this.displayOrder,
    required this.createdAt,
  });

  NutritionColumnEntity copyWith({
    int? id,
    String? name,
    NutritionColumnType? columnType,
    String? unit,
    int? displayOrder,
    DateTime? createdAt,
  }) {
    return NutritionColumnEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      columnType: columnType ?? this.columnType,
      unit: unit ?? this.unit,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
