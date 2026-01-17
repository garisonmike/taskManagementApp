import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/inactivity_reminder_service.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_log_entity.dart';
import '../../domain/repositories/task_log_repository.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/utils/task_sorter.dart';
import 'task_log_provider.dart';

/// Provider for TaskRepository
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl();
});

/// Provider for sort order preference
final taskSortOrderProvider = StateProvider<TaskSortOrder>((ref) {
  return TaskSortOrder.byType; // Default sort order
});

/// Provider for task search query
final taskSearchQueryProvider = StateProvider<String>((ref) => '');

/// State notifier for managing tasks
class TaskNotifier extends StateNotifier<AsyncValue<List<TaskEntity>>> {
  final TaskRepository _repository;
  final TaskLogRepository? _logRepository;

  TaskNotifier(this._repository, {TaskLogRepository? logRepository})
    : _logRepository = logRepository,
      super(const AsyncValue.loading()) {
    loadTasks();
  }

  /// Load all tasks from repository
  Future<void> loadTasks() async {
    if (!mounted) return;
    state = const AsyncValue.loading();
    try {
      final tasks = await _repository.getAllTasks();
      if (!mounted) return;
      state = AsyncValue.data(tasks);
    } catch (error, stackTrace) {
      if (!mounted) return;
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Add a new task
  Future<void> addTask(TaskEntity task) async {
    try {
      await _repository.createTask(task);
      await _logAction(task.id, TaskLogAction.created);
      if (!mounted) return;
      await loadTasks(); // Refresh the list
      await _updateInactivityReminder();
    } catch (error, stackTrace) {
      if (!mounted) return;
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Update an existing task
  Future<void> updateTask(TaskEntity task) async {
    try {
      // Fetch old task to detect state changes
      final oldTask = await _repository.getTaskById(task.id);

      await _repository.updateTask(task);

      // Determine the appropriate log action based on state changes
      TaskLogAction action = TaskLogAction.edited;
      Map<String, dynamic>? metadata;

      if (oldTask != null) {
        // Check for state transitions
        if (!oldTask.isCompleted && task.isCompleted) {
          if (task.failureReason != null && task.failureReason!.isNotEmpty) {
            action = TaskLogAction.failed;
            metadata = {'reason': task.failureReason};
          } else {
            action = TaskLogAction.completed;
          }
        } else if (!oldTask.isPostponed && task.isPostponed) {
          action = TaskLogAction.postponed;
        } else if (!oldTask.isDropped && task.isDropped) {
          action = TaskLogAction.dropped;
        }
      }

      await _logAction(task.id, action, metadata);

      // Check if still mounted before updating state
      if (!mounted) return;
      await loadTasks(); // Refresh the list
    } catch (error, stackTrace) {
      if (!mounted) return;
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Delete a task
  Future<void> deleteTask(String id) async {
    try {
      await _repository.deleteTask(id);
      await _logAction(id, TaskLogAction.deleted);
      if (!mounted) return;
      await loadTasks(); // Refresh the list
      await _updateInactivityReminder();
    } catch (error, stackTrace) {
      if (!mounted) return;
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Log a task action
  Future<void> _logAction(
    String taskId,
    TaskLogAction action, [
    Map<String, dynamic>? metadata,
  ]) async {
    if (_logRepository == null) return;

    final log = TaskLogEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      taskId: taskId,
      action: action,
      timestamp: DateTime.now(),
      metadata: metadata,
    );

    try {
      await _logRepository.createLog(log);
    } catch (error) {
      // Silently fail - logging should not break core functionality
    }
  }

  /// Update inactivity reminder based on task count
  Future<void> _updateInactivityReminder() async {
    try {
      final service = InactivityReminderService();
      await service.updateReminderBasedOnTasks();
    } catch (error) {
      // Silently fail - inactivity reminder is not critical
    }
  }

  /// Get a specific task by ID
  Future<TaskEntity?> getTaskById(String id) async {
    try {
      return await _repository.getTaskById(id);
    } catch (error) {
      return null;
    }
  }

  /// Bulk delete tasks
  Future<void> bulkDeleteTasks(List<String> taskIds) async {
    try {
      for (final id in taskIds) {
        await _repository.deleteTask(id);
        await _logAction(id, TaskLogAction.deleted);
      }
      if (!mounted) return;
      await loadTasks();
      await _updateInactivityReminder();
    } catch (error, stackTrace) {
      if (!mounted) return;
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Bulk complete tasks
  Future<void> bulkCompleteTasks(List<String> taskIds) async {
    try {
      for (final id in taskIds) {
        final task = await _repository.getTaskById(id);
        if (task != null && !task.isCompleted) {
          final updated = task.copyWith(
            isCompleted: true,
            completionDate: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await _repository.updateTask(updated);
          await _logAction(id, TaskLogAction.completed);
        }
      }
      if (!mounted) return;
      await loadTasks();
    } catch (error, stackTrace) {
      if (!mounted) return;
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// Provider for TaskNotifier
final taskNotifierProvider =
    StateNotifierProvider<TaskNotifier, AsyncValue<List<TaskEntity>>>((ref) {
      final repository = ref.watch(taskRepositoryProvider);
      final logRepository = ref.watch(taskLogRepositoryProvider);
      return TaskNotifier(repository, logRepository: logRepository);
    });

/// Provider for sorted tasks based on user's preference
final sortedTasksProvider = Provider<AsyncValue<List<TaskEntity>>>((ref) {
  final tasksAsyncValue = ref.watch(taskNotifierProvider);
  final sortOrder = ref.watch(taskSortOrderProvider);
  final searchQuery = ref.watch(taskSearchQueryProvider).toLowerCase();

  return tasksAsyncValue.whenData((tasks) {
    var filteredTasks = tasks;

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      filteredTasks = tasks.where((task) {
        final titleMatch = task.title.toLowerCase().contains(searchQuery);
        final descMatch =
            task.description?.toLowerCase().contains(searchQuery) ?? false;
        return titleMatch || descMatch;
      }).toList();
    }

    return TaskSorter.sort(filteredTasks, sortOrder);
  });
});
