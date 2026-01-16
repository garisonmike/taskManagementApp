class FoodNutritionValueEntity {
  final int? id;
  final int foodId;
  final int nutritionColumnId;
  final String value; // Stored as string, can be parsed based on column type
  final DateTime createdAt;

  const FoodNutritionValueEntity({
    this.id,
    required this.foodId,
    required this.nutritionColumnId,
    required this.value,
    required this.createdAt,
  });

  FoodNutritionValueEntity copyWith({
    int? id,
    int? foodId,
    int? nutritionColumnId,
    String? value,
    DateTime? createdAt,
  }) {
    return FoodNutritionValueEntity(
      id: id ?? this.id,
      foodId: foodId ?? this.foodId,
      nutritionColumnId: nutritionColumnId ?? this.nutritionColumnId,
      value: value ?? this.value,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
