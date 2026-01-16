class FoodEntity {
  final int? id;
  final String name;
  final String? description;
  final double? servingSize; // in grams
  final double? calories;
  final double? protein; // in grams
  final double? carbs; // in grams
  final double? fat; // in grams
  final double? fiber; // in grams
  final DateTime createdAt;
  final DateTime updatedAt;

  const FoodEntity({
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

  FoodEntity copyWith({
    int? id,
    String? name,
    String? description,
    double? servingSize,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? fiber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FoodEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      servingSize: servingSize ?? this.servingSize,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
