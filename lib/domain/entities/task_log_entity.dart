/// Types of task log actions
enum TaskLogAction {
  created,
  completed,
  failed,
  postponed,
  dropped,
  edited,
  deleted,
}

/// Domain entity representing an immutable log entry for task operations
///
/// Task logs are append-only and persist all task operations for analytics
/// and audit purposes.
class TaskLogEntity {
  final String id;
  final String taskId;
  final TaskLogAction action;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const TaskLogEntity({
    required this.id,
    required this.taskId,
    required this.action,
    required this.timestamp,
    this.metadata,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskLogEntity &&
        other.id == id &&
        other.taskId == taskId &&
        other.action == action &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => Object.hash(id, taskId, action, timestamp);
}
