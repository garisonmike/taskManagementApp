/// Priority levels for reminders
enum ReminderPriority {
  /// Normal priority - silent notification
  normal,

  /// Urgent priority - sound notification
  urgent,
}

/// Reminder entity - immutable domain model
class ReminderEntity {
  final String id;
  final String taskId; // Associated task
  final DateTime reminderTime;
  final bool isEnabled;
  final ReminderPriority priority;
  final DateTime createdAt;

  const ReminderEntity({
    required this.id,
    required this.taskId,
    required this.reminderTime,
    this.isEnabled = true,
    this.priority = ReminderPriority.normal,
    required this.createdAt,
  });

  /// Copy with method for immutability
  ReminderEntity copyWith({
    String? id,
    String? taskId,
    DateTime? reminderTime,
    bool? isEnabled,
    ReminderPriority? priority,
    DateTime? createdAt,
  }) {
    return ReminderEntity(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      reminderTime: reminderTime ?? this.reminderTime,
      isEnabled: isEnabled ?? this.isEnabled,
      priority: priority ?? this.priority,
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
        other.priority == priority &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      taskId,
      reminderTime,
      isEnabled,
      priority,
      createdAt,
    );
  }
}
