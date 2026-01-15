/// Types of meal log actions
enum MealLogAction { consumed, edited, deleted }

/// Domain entity representing an immutable log entry for meal operations
///
/// Meal logs are append-only and persist all meal operations for analytics
/// Optional integration with task logs for unified activity tracking
class MealLogEntity {
  final String id;
  final String mealId;
  final MealLogAction action;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const MealLogEntity({
    required this.id,
    required this.mealId,
    required this.action,
    required this.timestamp,
    this.metadata,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MealLogEntity &&
        other.id == id &&
        other.mealId == mealId &&
        other.action == action &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => Object.hash(id, mealId, action, timestamp);
}
