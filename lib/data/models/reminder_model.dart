import '../../domain/entities/reminder_entity.dart';

/// Reminder model for data layer (JSON serialization and database mapping)
class ReminderModel {
  final String id;
  final String taskId;
  final int reminderTime; // stored as epoch milliseconds
  final int isEnabled; // stored as 0 or 1 in DB
  final String priority; // stored as 'normal' or 'urgent'
  final int createdAt; // stored as epoch milliseconds

  ReminderModel({
    required this.id,
    required this.taskId,
    required this.reminderTime,
    required this.isEnabled,
    required this.priority,
    required this.createdAt,
  });

  /// Convert to entity (domain model)
  ReminderEntity toEntity() {
    return ReminderEntity(
      id: id,
      taskId: taskId,
      reminderTime: DateTime.fromMillisecondsSinceEpoch(reminderTime),
      isEnabled: isEnabled == 1,
      priority: priority == 'urgent'
          ? ReminderPriority.urgent
          : ReminderPriority.normal,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
    );
  }

  /// Convert from entity (domain model)
  factory ReminderModel.fromEntity(ReminderEntity entity) {
    return ReminderModel(
      id: entity.id,
      taskId: entity.taskId,
      reminderTime: entity.reminderTime.millisecondsSinceEpoch,
      isEnabled: entity.isEnabled ? 1 : 0,
      priority: entity.priority == ReminderPriority.urgent
          ? 'urgent'
          : 'normal',
      createdAt: entity.createdAt.millisecondsSinceEpoch,
    );
  }

  /// Convert to map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'reminder_time': reminderTime,
      'is_enabled': isEnabled,
      'priority': priority,
      'created_at': createdAt,
    };
  }

  /// Convert from database map
  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'] as String,
      taskId: map['task_id'] as String,
      reminderTime: map['reminder_time'] as int,
      isEnabled: map['is_enabled'] as int,
      priority:
          (map['priority'] as String?) ??
          'normal', // Default to normal for backwards compatibility
      createdAt: map['created_at'] as int,
    );
  }
}
