import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/local/task_local_data_source.dart';

/// Implementation of TaskRepository using local database
class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource _localDataSource;

  TaskRepositoryImpl({TaskLocalDataSource? localDataSource})
    : _localDataSource = localDataSource ?? TaskLocalDataSource();

  @override
  Future<List<TaskEntity>> getAllTasks() async {
    return await _localDataSource.getAllTasks();
  }

  @override
  Future<TaskEntity?> getTaskById(String id) async {
    return await _localDataSource.getTaskById(id);
  }

  @override
  Future<void> createTask(TaskEntity task) async {
    await _localDataSource.insertTask(task);
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    await _localDataSource.updateTask(task);
  }

  @override
  Future<void> deleteTask(String id) async {
    await _localDataSource.deleteTask(id);
  }

  @override
  Future<List<TaskEntity>> getTasksByStatus({required bool isCompleted}) async {
    return await _localDataSource.getTasksByStatus(isCompleted: isCompleted);
  }

  @override
  Future<List<TaskEntity>> getTasksByType(TaskType type) async {
    return await _localDataSource.getTasksByType(type);
  }
}
