/// Meal entity representing a meal entry
/// Completely decoupled from tasks
class MealEntity {
  final String id;
  final String name;
  final String? description;
  final MealType mealType;
  final DateTime consumedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MealEntity({
    required this.id,
    required this.name,
    this.description,
    required this.mealType,
    required this.consumedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  MealEntity copyWith({
    String? id,
    String? name,
    String? description,
    MealType? mealType,
    DateTime? consumedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MealEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      mealType: mealType ?? this.mealType,
      consumedAt: consumedAt ?? this.consumedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Types of meals
enum MealType {
  breakfast,
  lunch,
  dinner,
  snack;

  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }
}
