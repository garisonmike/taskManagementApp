import '../../domain/entities/task_entity.dart';

/// Repository interface for task operations
abstract class TaskRepository {
  Future<List<TaskEntity>> getAllTasks();
  Future<TaskEntity?> getTaskById(String id);
  Future<void> createTask(TaskEntity task);
  Future<void> updateTask(TaskEntity task);
  Future<void> deleteTask(String id);
  Future<List<TaskEntity>> getTasksByStatus({required bool isCompleted});
  Future<List<TaskEntity>> getTasksByType(TaskType type);
}
