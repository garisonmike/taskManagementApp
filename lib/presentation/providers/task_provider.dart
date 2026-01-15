import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/inactivity_reminder_service.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';

/// Provider for TaskRepository
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl();
});

/// State notifier for managing tasks
class TaskNotifier extends StateNotifier<AsyncValue<List<TaskEntity>>> {
  final TaskRepository _repository;

  TaskNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadTasks();
  }

  /// Load all tasks from repository
  Future<void> loadTasks() async {
    state = const AsyncValue.loading();
    try {
      final tasks = await _repository.getAllTasks();
      state = AsyncValue.data(tasks);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Add a new task
  Future<void> addTask(TaskEntity task) async {
    try {
      await _repository.createTask(task);
      await loadTasks(); // Refresh the list
      await _updateInactivityReminder();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Update an existing task
  Future<void> updateTask(TaskEntity task) async {
    try {
      await _repository.updateTask(task);
      await loadTasks(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Delete a task
  Future<void> deleteTask(String id) async {
    try {
      await _repository.deleteTask(id);
      await loadTasks(); // Refresh the list
      await _updateInactivityReminder();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
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
}

/// Provider for TaskNotifier
final taskNotifierProvider =
    StateNotifierProvider<TaskNotifier, AsyncValue<List<TaskEntity>>>((ref) {
      final repository = ref.watch(taskRepositoryProvider);
      return TaskNotifier(repository);
    });
