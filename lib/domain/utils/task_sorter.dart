import '../entities/task_entity.dart';

/// Enum for sort order preferences
enum TaskSortOrder {
  /// Default: type-based (timeBased → deadline → unsure), then by status
  byType,

  /// Sort by creation date (newest first)
  byCreatedDate,

  /// Sort by priority (urgent first), then by type
  byPriority,
}

/// Utility class for sorting tasks
class TaskSorter {
  /// Sort tasks according to the specified order
  static List<TaskEntity> sort(
    List<TaskEntity> tasks,
    TaskSortOrder sortOrder,
  ) {
    final sorted = List<TaskEntity>.from(tasks);

    switch (sortOrder) {
      case TaskSortOrder.byType:
        sorted.sort(_compareByType);
        break;
      case TaskSortOrder.byCreatedDate:
        sorted.sort(_compareByCreatedDate);
        break;
      case TaskSortOrder.byPriority:
        sorted.sort(_compareByPriority);
        break;
    }

    return sorted;
  }

  /// Compare by type: timeBased → deadline (nearest first) → unsure
  /// Within each type, sort by status: incomplete → completed → failed
  static int _compareByType(TaskEntity a, TaskEntity b) {
    // First sort by status: incomplete → completed → failed
    final statusA = _getStatusPriority(a);
    final statusB = _getStatusPriority(b);
    if (statusA != statusB) {
      return statusA.compareTo(statusB);
    }

    // Then sort by task type
    final typeOrderA = _getTypeOrder(a.taskType);
    final typeOrderB = _getTypeOrder(b.taskType);
    if (typeOrderA != typeOrderB) {
      return typeOrderA.compareTo(typeOrderB);
    }

    // Within same type, apply specific sorting
    if (a.taskType == TaskType.timeBased && b.taskType == TaskType.timeBased) {
      // Sort time-based tasks by start time
      if (a.timeBasedStart != null && b.timeBasedStart != null) {
        return a.timeBasedStart!.compareTo(b.timeBasedStart!);
      }
    } else if (a.taskType == TaskType.deadline &&
        b.taskType == TaskType.deadline) {
      // Sort deadline tasks by deadline (nearest first)
      if (a.deadline != null && b.deadline != null) {
        return a.deadline!.compareTo(b.deadline!);
      }
    }

    // Default to creation date (newest first)
    return b.createdAt.compareTo(a.createdAt);
  }

  /// Compare by creation date (newest first)
  static int _compareByCreatedDate(TaskEntity a, TaskEntity b) {
    // First sort by status
    final statusA = _getStatusPriority(a);
    final statusB = _getStatusPriority(b);
    if (statusA != statusB) {
      return statusA.compareTo(statusB);
    }

    // Then by creation date (newest first)
    return b.createdAt.compareTo(a.createdAt);
  }

  /// Compare by priority (urgent first), then by type
  static int _compareByPriority(TaskEntity a, TaskEntity b) {
    // First sort by status
    final statusA = _getStatusPriority(a);
    final statusB = _getStatusPriority(b);
    if (statusA != statusB) {
      return statusA.compareTo(statusB);
    }

    // Then by priority (urgent first)
    final priorityA = a.priority == TaskPriority.urgent ? 0 : 1;
    final priorityB = b.priority == TaskPriority.urgent ? 0 : 1;
    if (priorityA != priorityB) {
      return priorityA.compareTo(priorityB);
    }

    // Then by type
    return _compareByType(a, b);
  }

  /// Get status priority (lower number = higher priority)
  /// incomplete (0) → completed (1) → failed (2)
  static int _getStatusPriority(TaskEntity task) {
    if (!task.isCompleted) {
      return 0; // Incomplete tasks first
    } else if (task.failureReason != null && task.failureReason!.isNotEmpty) {
      return 2; // Failed tasks last
    } else {
      return 1; // Completed tasks in the middle
    }
  }

  /// Get type order (lower number = higher priority)
  /// timeBased (0) → deadline (1) → unsure (2)
  static int _getTypeOrder(TaskType type) {
    switch (type) {
      case TaskType.timeBased:
        return 0;
      case TaskType.deadline:
        return 1;
      case TaskType.unsure:
        return 2;
    }
  }
}
