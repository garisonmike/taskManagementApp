/// Domain entity representing a task template within a Blueprint
///
/// BlueprintTask defines the template for tasks that will be generated
/// from a blueprint. It contains the basic task information without
/// specific dates or completion status.
class BlueprintTaskEntity {
  final String id;
  final String blueprintId;
  final String title;
  final String? description;
  final String taskType; // 'unsure', 'deadline', 'timeBased'
  final String? defaultTime; // HH:mm format for default time
  final DateTime createdAt;

  const BlueprintTaskEntity({
    required this.id,
    required this.blueprintId,
    required this.title,
    this.description,
    required this.taskType,
    this.defaultTime,
    required this.createdAt,
  });

  /// Create a copy of this entity with updated fields
  BlueprintTaskEntity copyWith({
    String? id,
    String? blueprintId,
    String? title,
    String? description,
    String? taskType,
    String? defaultTime,
    DateTime? createdAt,
  }) {
    return BlueprintTaskEntity(
      id: id ?? this.id,
      blueprintId: blueprintId ?? this.blueprintId,
      title: title ?? this.title,
      description: description ?? this.description,
      taskType: taskType ?? this.taskType,
      defaultTime: defaultTime ?? this.defaultTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BlueprintTaskEntity &&
        other.id == id &&
        other.blueprintId == blueprintId &&
        other.title == title &&
        other.description == description &&
        other.taskType == taskType &&
        other.defaultTime == defaultTime &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(
    id,
    blueprintId,
    title,
    description,
    taskType,
    defaultTime,
    createdAt,
  );
}
