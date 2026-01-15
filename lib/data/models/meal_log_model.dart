import '../../domain/entities/meal_log_entity.dart';

/// Data model for MealLog persistence
class MealLogModel {
  final String id;
  final String mealId;
  final String action;
  final int timestamp;
  final String? metadata;

  const MealLogModel({
    required this.id,
    required this.mealId,
    required this.action,
    required this.timestamp,
    this.metadata,
  });

  /// Convert model to entity
  MealLogEntity toEntity() {
    return MealLogEntity(
      id: id,
      mealId: mealId,
      action: MealLogAction.values.firstWhere(
        (e) => e.name == action,
        orElse: () => MealLogAction.consumed,
      ),
      timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp),
      metadata: metadata != null ? _parseMetadata(metadata!) : null,
    );
  }

  /// Create model from entity
  factory MealLogModel.fromEntity(MealLogEntity entity) {
    return MealLogModel(
      id: entity.id,
      mealId: entity.mealId,
      action: entity.action.name,
      timestamp: entity.timestamp.millisecondsSinceEpoch,
      metadata: entity.metadata?.toString(),
    );
  }

  /// Create model from database map
  factory MealLogModel.fromMap(Map<String, dynamic> map) {
    return MealLogModel(
      id: map['id'] as String,
      mealId: map['meal_id'] as String,
      action: map['action'] as String,
      timestamp: map['timestamp'] as int,
      metadata: map['metadata'] as String?,
    );
  }

  /// Convert model to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'meal_id': mealId,
      'action': action,
      'timestamp': timestamp,
      'metadata': metadata,
    };
  }

  /// Parse metadata string to map (simple implementation)
  static Map<String, dynamic>? _parseMetadata(String metadata) {
    try {
      // For simple cases, just return a map with the raw string
      return {'raw': metadata};
    } catch (_) {
      return null;
    }
  }
}
