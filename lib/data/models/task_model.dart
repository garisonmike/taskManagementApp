import '../../domain/entities/task_entity.dart';

/// Task model for data layer (JSON serialization and database mapping)
class TaskModel {
  final String id;
  final String title;
  final String? description;
  final String taskType; // stored as string in DB
  final String priority; // stored as string in DB
  final int? deadline; // stored as epoch milliseconds
  final int? timeBasedStart; // stored as epoch milliseconds
  final int? timeBasedEnd; // stored as epoch milliseconds
  final int isCompleted; // stored as 0 or 1 in DB
  final int? completionDate; // stored as epoch milliseconds
  final String? failureReason;
  final int isPostponed; // stored as 0 or 1 in DB
  final int isDropped; // stored as 0 or 1 in DB
  final int createdAt; // stored as epoch milliseconds
  final int updatedAt; // stored as epoch milliseconds

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.taskType,
    this.priority = 'normal',
    this.deadline,
    this.timeBasedStart,
    this.timeBasedEnd,
    required this.isCompleted,
    this.completionDate,
    this.failureReason,
    required this.isPostponed,
    required this.isDropped,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert to entity (domain model)
  TaskEntity toEntity() {
    return TaskEntity(
      id: id,
      title: title,
      description: description,
      taskType: TaskType.values.firstWhere(
        (t) => t.name == taskType,
        orElse: () => TaskType.unsure,
      ),
      priority: TaskPriority.values.firstWhere(
        (p) => p.name == priority,
        orElse: () => TaskPriority.normal,
      ),
      deadline: deadline != null
          ? DateTime.fromMillisecondsSinceEpoch(deadline!)
          : null,
      timeBasedStart: timeBasedStart != null
          ? DateTime.fromMillisecondsSinceEpoch(timeBasedStart!)
          : null,
      timeBasedEnd: timeBasedEnd != null
          ? DateTime.fromMillisecondsSinceEpoch(timeBasedEnd!)
          : null,
      isCompleted: isCompleted == 1,
      completionDate: completionDate != null
          ? DateTime.fromMillisecondsSinceEpoch(completionDate!)
          : null,
      failureReason: failureReason,
      isPostponed: isPostponed == 1,
      isDropped: isDropped == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
    );
  }

  /// Convert from entity (domain model)
  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      taskType: entity.taskType.name,
      priority: entity.priority.name,
      deadline: entity.deadline?.millisecondsSinceEpoch,
      timeBasedStart: entity.timeBasedStart?.millisecondsSinceEpoch,
      timeBasedEnd: entity.timeBasedEnd?.millisecondsSinceEpoch,
      isCompleted: entity.isCompleted ? 1 : 0,
      completionDate: entity.completionDate?.millisecondsSinceEpoch,
      failureReason: entity.failureReason,
      isPostponed: entity.isPostponed ? 1 : 0,
      isDropped: entity.isDropped ? 1 : 0,
      createdAt: entity.createdAt.millisecondsSinceEpoch,
      updatedAt: entity.updatedAt.millisecondsSinceEpoch,
    );
  }

  /// Convert to map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'task_type': taskType,
      'priority': priority,
      'deadline': deadline,
      'time_based_start': timeBasedStart,
      'time_based_end': timeBasedEnd,
      'is_completed': isCompleted,
      'completion_date': completionDate,
      'failure_reason': failureReason,
      'is_postponed': isPostponed,
      'is_dropped': isDropped,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Convert from database map
  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      taskType: map['task_type'] as String,
      priority: (map['priority'] as String?) ?? 'normal',
      deadline: map['deadline'] as int?,
      timeBasedStart: map['time_based_start'] as int?,
      timeBasedEnd: map['time_based_end'] as int?,
      isCompleted: map['is_completed'] as int,
      completionDate: map['completion_date'] as int?,
      failureReason: map['failure_reason'] as String?,
      isPostponed: map['is_postponed'] as int,
      isDropped: map['is_dropped'] as int,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }
}
