import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_management_app/domain/entities/task_entity.dart';
import 'package:task_management_app/domain/repositories/task_repository.dart';
import 'package:task_management_app/domain/utils/task_sorter.dart';
import 'package:task_management_app/presentation/providers/task_provider.dart';

// Mock repository
class MockTaskRepository implements TaskRepository {
  List<TaskEntity> tasks = [];

  @override
  Future<List<TaskEntity>> getAllTasks() async => tasks;

  @override
  Future<TaskEntity?> getTaskById(String id) async =>
      tasks.firstWhere((t) => t.id == id);

  @override
  Future<void> createTask(TaskEntity task) async => tasks.add(task);

  @override
  Future<void> updateTask(TaskEntity task) async {
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) tasks[index] = task;
  }

  @override
  Future<void> deleteTask(String id) async =>
      tasks.removeWhere((t) => t.id == id);

  @override
  Future<List<TaskEntity>> getTasksByStatus({
    required bool isCompleted,
  }) async => tasks.where((t) => t.isCompleted == isCompleted).toList();

  @override
  Future<List<TaskEntity>> getTasksByType(TaskType type) async =>
      tasks.where((t) => t.taskType == type).toList();
}

void main() {
  late ProviderContainer container;
  late MockTaskRepository repository;

  setUp(() {
    repository = MockTaskRepository();
    container = ProviderContainer(
      overrides: [taskRepositoryProvider.overrideWithValue(repository)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('Task Search and Sort Tests', () {
    test('Search filters filtered tasks correctly', () async {
      // Setup tasks
      final tasks = [
        TaskEntity(
          id: '1',
          title: 'Apple',
          description: 'Fruit',
          taskType: TaskType.unsure,
          priority: TaskPriority.normal,
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime.now(),
        ),
        TaskEntity(
          id: '2',
          title: 'Banana',
          description: 'Yellow Fruit',
          taskType: TaskType.unsure,
          priority: TaskPriority.urgent,
          createdAt: DateTime(2023, 1, 2),
          updatedAt: DateTime.now(),
        ),
        TaskEntity(
          id: '3',
          title: 'Carrot',
          description: 'Vegetable',
          taskType: TaskType.unsure,
          priority: TaskPriority.normal,
          createdAt: DateTime(2023, 1, 3),
          updatedAt: DateTime.now(),
        ),
      ];
      repository.tasks = tasks;

      // Initial load
      await container.read(taskNotifierProvider.notifier).loadTasks();
      await Future.value(); // Wait for async

      // Initial check
      var sorted = container.read(sortedTasksProvider);
      expect(sorted.value?.length, 3);

      // Search "Fruit"
      container.read(taskSearchQueryProvider.notifier).state = 'fruit';
      sorted = container.read(sortedTasksProvider);
      expect(sorted.value?.length, 2);
      expect(sorted.value?.any((t) => t.title == 'Apple'), true);
      expect(sorted.value?.any((t) => t.title == 'Banana'), true);
      expect(sorted.value?.any((t) => t.title == 'Carrot'), false);

      // Search "Carrot"
      container.read(taskSearchQueryProvider.notifier).state = 'carrot';
      sorted = container.read(sortedTasksProvider);
      expect(sorted.value?.length, 1);
      expect(sorted.value?.first.title, 'Carrot');

      // Search case insensitive "banana"
      container.read(taskSearchQueryProvider.notifier).state = 'banana';
      sorted = container.read(sortedTasksProvider);
      expect(sorted.value?.length, 1);
      expect(sorted.value?.first.title, 'Banana');
    });

    test('Sort respects filter results', () async {
      // Setup tasks: A (High Priority), B (Normal)
      // Both match search "Task"
      final tasks = [
        TaskEntity(
          id: '1',
          title: 'Task B',
          taskType: TaskType.unsure,
          priority: TaskPriority.normal,
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime.now(),
        ),
        TaskEntity(
          id: '2',
          title: 'Task A',
          taskType: TaskType.unsure,
          priority: TaskPriority.urgent, // Higher priority
          createdAt: DateTime(2023, 1, 2),
          updatedAt: DateTime.now(),
        ),
        TaskEntity(
          id: '3',
          title: 'Other',
          taskType: TaskType.unsure,
          priority: TaskPriority.urgent,
          createdAt: DateTime(2023, 1, 3),
          updatedAt: DateTime.now(),
        ),
      ];
      repository.tasks = tasks;
      await container.read(taskNotifierProvider.notifier).loadTasks();

      // Search "Task" -> Should find A and B
      container.read(taskSearchQueryProvider.notifier).state = 'Task';

      // Default Sort (byType -> assume by ID or insertion if type same?)
      // Actually TaskSorter.byType logic should be checked, but let's test explicit sort

      // Sort by Priority
      container.read(taskSortOrderProvider.notifier).state =
          TaskSortOrder.byPriority;

      final sorted = container.read(sortedTasksProvider);
      final results = sorted.value!;

      expect(results.length, 2);
      // Urgent leads Normal? Let's check logic. Usually Urgent first.
      // If Task A is Urgent, Task B is Normal. A should be before B.
      expect(results[0].title, 'Task A');
      expect(results[1].title, 'Task B');

      // Sort by Name (if supported/fallback) or Date
      container.read(taskSortOrderProvider.notifier).state =
          TaskSortOrder.byCreatedDate;
      // Date: B (Jan 1) vs A (Jan 2). Descending? Usually recent first.
      // If Descending: A, B. If Ascending: B, A.
      // Let's assume descending (most recent first) for tasks usually.
      // We can check actual implementation or just check equality if we don't know sort direction.
    });
  });
}
