/// Reminder entity - immutable domain model
class ReminderEntity {
  final String id;
  final String taskId; // Associated task
  final DateTime reminderTime;
  final bool isEnabled;
  final DateTime createdAt;

  const ReminderEntity({
    required this.id,
    required this.taskId,
    required this.reminderTime,
    this.isEnabled = true,
    required this.createdAt,
  });

  /// Copy with method for immutability
  ReminderEntity copyWith({
    String? id,
    String? taskId,
    DateTime? reminderTime,
    bool? isEnabled,
    DateTime? createdAt,
  }) {
    return ReminderEntity(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      reminderTime: reminderTime ?? this.reminderTime,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ReminderEntity &&
        other.id == id &&
        other.taskId == taskId &&
        other.reminderTime == reminderTime &&
        other.isEnabled == isEnabled &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, taskId, reminderTime, isEnabled, createdAt);
  }
}
