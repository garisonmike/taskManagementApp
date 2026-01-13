import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:task_management_app/data/datasources/local/database_helper.dart';
import 'package:task_management_app/data/datasources/local/task_local_data_source.dart';
import 'package:task_management_app/data/repositories/task_repository_impl.dart';
import 'package:task_management_app/domain/entities/task_entity.dart';

void main() {
  late TaskRepositoryImpl repository;
  late TaskLocalDataSource dataSource;
  late DatabaseHelper databaseHelper;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() {
    databaseHelper = DatabaseHelper.test(inMemoryDatabasePath);
    dataSource = TaskLocalDataSource(databaseHelper: databaseHelper);
    repository = TaskRepositoryImpl(localDataSource: dataSource);
  });

  tearDown(() async {
    await databaseHelper.close();
  });

  group('TaskRepositoryImpl', () {
    test('getAllTasks delegates to data source', () async {
      final task = TaskEntity(
        id: '1',
        title: 'Test Task',
        description: null,
        taskType: TaskType.unsure,
        isCompleted: false,
        isPostponed: false,
        isDropped: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await dataSource.insertTask(task);

      final tasks = await repository.getAllTasks();
      expect(tasks.length, 1);
      expect(tasks.first.title, 'Test Task');
    });

    test('getTaskById delegates to data source', () async {
      final task = TaskEntity(
        id: 'specific-id',
        title: 'Specific Task',
        description: null,
        taskType: TaskType.unsure,
        isCompleted: false,
        isPostponed: false,
        isDropped: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await dataSource.insertTask(task);

      final retrieved = await repository.getTaskById('specific-id');
      expect(retrieved, isNotNull);
      expect(retrieved!.title, 'Specific Task');
    });

    test('createTask adds task via data source', () async {
      final task = TaskEntity(
        id: 'new-task',
        title: 'New Task',
        description: null,
        taskType: TaskType.unsure,
        isCompleted: false,
        isPostponed: false,
        isDropped: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createTask(task);

      final tasks = await repository.getAllTasks();
      expect(tasks.length, 1);
      expect(tasks.first.id, 'new-task');
    });

    test('updateTask modifies task via data source', () async {
      final task = TaskEntity(
        id: 'update-task',
        title: 'Original',
        description: null,
        taskType: TaskType.unsure,
        isCompleted: false,
        isPostponed: false,
        isDropped: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createTask(task);

      final updated = task.copyWith(
        title: 'Modified',
        updatedAt: DateTime.now(),
      );
      await repository.updateTask(updated);

      final retrieved = await repository.getTaskById('update-task');
      expect(retrieved!.title, 'Modified');
    });

    test('deleteTask removes task via data source', () async {
      final task = TaskEntity(
        id: 'delete-task',
        title: 'To Delete',
        description: null,
        taskType: TaskType.unsure,
        isCompleted: false,
        isPostponed: false,
        isDropped: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createTask(task);
      expect((await repository.getAllTasks()).length, 1);

      await repository.deleteTask('delete-task');
      expect((await repository.getAllTasks()).length, 0);
    });

    test('getTasksByStatus filters correctly', () async {
      final completedTask = TaskEntity(
        id: '1',
        title: 'Completed',
        description: null,
        taskType: TaskType.unsure,
        isCompleted: true,
        completionDate: DateTime.now(),
        isPostponed: false,
        isDropped: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final incompleteTask = TaskEntity(
        id: '2',
        title: 'Incomplete',
        description: null,
        taskType: TaskType.unsure,
        isCompleted: false,
        isPostponed: false,
        isDropped: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createTask(completedTask);
      await repository.createTask(incompleteTask);

      final completed = await repository.getTasksByStatus(isCompleted: true);
      final incomplete = await repository.getTasksByStatus(isCompleted: false);

      expect(completed.length, 1);
      expect(completed.first.title, 'Completed');
      expect(incomplete.length, 1);
      expect(incomplete.first.title, 'Incomplete');
    });

    test('getTasksByType filters correctly', () async {
      final unsureTask = TaskEntity(
        id: '1',
        title: 'Unsure Task',
        description: null,
        taskType: TaskType.unsure,
        isCompleted: false,
        isPostponed: false,
        isDropped: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final deadlineTask = TaskEntity(
        id: '2',
        title: 'Deadline Task',
        description: null,
        taskType: TaskType.deadline,
        deadline: DateTime(2024, 12, 31),
        isCompleted: false,
        isPostponed: false,
        isDropped: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createTask(unsureTask);
      await repository.createTask(deadlineTask);

      final unsureTasks = await repository.getTasksByType(TaskType.unsure);
      final deadlineTasks = await repository.getTasksByType(TaskType.deadline);

      expect(unsureTasks.length, 1);
      expect(unsureTasks.first.title, 'Unsure Task');
      expect(deadlineTasks.length, 1);
      expect(deadlineTasks.first.title, 'Deadline Task');
    });
  });
}
