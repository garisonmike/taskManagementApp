/// Types of tasks in the system
enum TaskType {
  /// Task with no specific deadline
  unsure,

  /// Task with a specific deadline date
  deadline,

  /// Task with specific start and end times
  timeBased,
}

/// Task entity - immutable domain model
class TaskEntity {
  final String id;
  final String title;
  final String? description;
  final TaskType taskType;

  // Time-related fields
  final DateTime? deadline; // For deadline tasks
  final DateTime? timeBasedStart; // For time-based tasks
  final DateTime? timeBasedEnd; // For time-based tasks

  // Status fields
  final bool isCompleted;
  final DateTime? completionDate;
  final String? failureReason; // Optional reason if task failed
  final bool isPostponed;
  final bool isDropped;

  // Metadata
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaskEntity({
    required this.id,
    required this.title,
    this.description,
    required this.taskType,
    this.deadline,
    this.timeBasedStart,
    this.timeBasedEnd,
    this.isCompleted = false,
    this.completionDate,
    this.failureReason,
    this.isPostponed = false,
    this.isDropped = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Copy with method for immutability
  TaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    TaskType? taskType,
    DateTime? deadline,
    DateTime? timeBasedStart,
    DateTime? timeBasedEnd,
    bool? isCompleted,
    DateTime? completionDate,
    String? failureReason,
    bool? isPostponed,
    bool? isDropped,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      taskType: taskType ?? this.taskType,
      deadline: deadline ?? this.deadline,
      timeBasedStart: timeBasedStart ?? this.timeBasedStart,
      timeBasedEnd: timeBasedEnd ?? this.timeBasedEnd,
      isCompleted: isCompleted ?? this.isCompleted,
      completionDate: completionDate ?? this.completionDate,
      failureReason: failureReason ?? this.failureReason,
      isPostponed: isPostponed ?? this.isPostponed,
      isDropped: isDropped ?? this.isDropped,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TaskEntity &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.taskType == taskType &&
        other.deadline == deadline &&
        other.timeBasedStart == timeBasedStart &&
        other.timeBasedEnd == timeBasedEnd &&
        other.isCompleted == isCompleted &&
        other.completionDate == completionDate &&
        other.failureReason == failureReason &&
        other.isPostponed == isPostponed &&
        other.isDropped == isDropped &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      description,
      taskType,
      deadline,
      timeBasedStart,
      timeBasedEnd,
      isCompleted,
      completionDate,
      failureReason,
      isPostponed,
      isDropped,
      createdAt,
      updatedAt,
    );
  }
}
