import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:task_management_app/data/datasources/local/database_helper.dart';
import 'package:task_management_app/data/datasources/local/task_local_data_source.dart';
import 'package:task_management_app/domain/entities/task_entity.dart';

void main() {
  late TaskLocalDataSource dataSource;
  late DatabaseHelper databaseHelper;

  setUpAll(() {
    // Initialize FFI for desktop testing
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // Use in-memory database for testing
    databaseHelper = DatabaseHelper.test(inMemoryDatabasePath);
    dataSource = TaskLocalDataSource(databaseHelper: databaseHelper);
  });

  tearDown(() async {
    await databaseHelper.close();
  });

  group('TaskLocalDataSource', () {
    test('getAllTasks returns empty list initially', () async {
      final tasks = await dataSource.getAllTasks();
      expect(tasks, isEmpty);
    });

    test('insertTask adds a task to database', () async {
      final task = TaskEntity(
        id: '1',
        title: 'Test Task',
        description: 'Test Description',
        taskType: TaskType.unsure,
        isCompleted: false,
        isPostponed: false,
        isDropped: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await dataSource.insertTask(task);
      final tasks = await dataSource.getAllTasks();

      expect(tasks.length, 1);
      expect(tasks.first.title, 'Test Task');
      expect(tasks.first.description, 'Test Description');
      expect(tasks.first.taskType, TaskType.unsure);
    });

    test('getTaskById returns correct task', () async {
      final task = TaskEntity(
        id: 'task-123',
        title: 'Specific Task',
        description: null,
        taskType: TaskType.deadline,
        deadline: DateTime(2024, 12, 31, 23, 59),
        isCompleted: false,
        isPostponed: false,
        isDropped: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await dataSource.insertTask(task);
      final retrieved = await dataSource.getTaskById('task-123');

      expect(retrieved, isNotNull);
      expect(retrieved!.id, 'task-123');
      expect(retrieved.title, 'Specific Task');
      expect(retrieved.taskType, TaskType.deadline);
    });

    test('getTaskById returns null for non-existent task', () async {
      final task = await dataSource.getTaskById('non-existent');
      expect(task, isNull);
    });

    test('updateTask modifies existing task', () async {
      final task = TaskEntity(
        id: 'update-test',
        title: 'Original Title',
        description: 'Original Description',
        taskType: TaskType.unsure,
        isCompleted: false,
        isPostponed: false,
        isDropped: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await dataSource.insertTask(task);

      final updated = task.copyWith(
        title: 'Updated Title',
        description: 'Updated Description',
        taskType: TaskType.deadline,
        updatedAt: DateTime.now(),
      );

      await dataSource.updateTask(updated);
      final retrieved = await dataSource.getTaskById('update-test');

      expect(retrieved!.title, 'Updated Title');
      expect(retrieved.description, 'Updated Description');
      expect(retrieved.taskType, TaskType.deadline);
    });

    test('deleteTask removes task from database', () async {
      final task = TaskEntity(
        id: 'delete-test',
        title: 'To Be Deleted',
        description: null,
        taskType: TaskType.unsure,
        isCompleted: false,
        isPostponed: false,
        isDropped: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await dataSource.insertTask(task);
      expect((await dataSource.getAllTasks()).length, 1);

      await dataSource.deleteTask('delete-test');
      expect((await dataSource.getAllTasks()).length, 0);
    });

    test('getTasksByStatus filters completed tasks correctly', () async {
      final task1 = TaskEntity(
        id: '1',
        title: 'Completed Task',
        description: null,
        taskType: TaskType.unsure,
        isCompleted: true,
        completionDate: DateTime.now(),
        isPostponed: false,
        isDropped: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final task2 = TaskEntity(
        id: '2',
        title: 'Incomplete Task',
        description: null,
        taskType: TaskType.unsure,
        isCompleted: false,
        isPostponed: false,
        isDropped: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await dataSource.insertTask(task1);
      await dataSource.insertTask(task2);

      final completed = await dataSource.getTasksByStatus(isCompleted: true);
      final incomplete = await dataSource.getTasksByStatus(isCompleted: false);

      expect(completed.length, 1);
      expect(completed.first.title, 'Completed Task');
      expect(incomplete.length, 1);
      expect(incomplete.first.title, 'Incomplete Task');
    });

    test('getTasksByType filters tasks by type', () async {
      final task1 = TaskEntity(
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

      final task2 = TaskEntity(
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

      final task3 = TaskEntity(
        id: '3',
        title: 'Time-based Task',
        description: null,
        taskType: TaskType.timeBased,
        timeBasedStart: DateTime(2024, 6, 1, 9, 0),
        timeBasedEnd: DateTime(2024, 6, 1, 17, 0),
        isCompleted: false,
        isPostponed: false,
        isDropped: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await dataSource.insertTask(task1);
      await dataSource.insertTask(task2);
      await dataSource.insertTask(task3);

      final unsureTasks = await dataSource.getTasksByType(TaskType.unsure);
      final deadlineTasks = await dataSource.getTasksByType(TaskType.deadline);
      final timeBasedTasks = await dataSource.getTasksByType(
        TaskType.timeBased,
      );

      expect(unsureTasks.length, 1);
      expect(unsureTasks.first.title, 'Unsure Task');
      expect(deadlineTasks.length, 1);
      expect(deadlineTasks.first.title, 'Deadline Task');
      expect(timeBasedTasks.length, 1);
      expect(timeBasedTasks.first.title, 'Time-based Task');
    });

    test('insertTask with deadline preserves datetime', () async {
      final deadline = DateTime(2024, 12, 25, 14, 30);
      final task = TaskEntity(
        id: 'deadline-task',
        title: 'Task with Deadline',
        description: null,
        taskType: TaskType.deadline,
        deadline: deadline,
        isCompleted: false,
        isPostponed: false,
        isDropped: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await dataSource.insertTask(task);
      final retrieved = await dataSource.getTaskById('deadline-task');

      expect(retrieved!.deadline, isNotNull);
      expect(retrieved.deadline!.year, deadline.year);
      expect(retrieved.deadline!.month, deadline.month);
      expect(retrieved.deadline!.day, deadline.day);
      expect(retrieved.deadline!.hour, deadline.hour);
      expect(retrieved.deadline!.minute, deadline.minute);
    });

    test('insertTask with time-based range preserves datetimes', () async {
      final start = DateTime(2024, 6, 15, 9, 0);
      final end = DateTime(2024, 6, 15, 17, 30);

      final task = TaskEntity(
        id: 'time-based-task',
        title: 'Time-based Task',
        description: null,
        taskType: TaskType.timeBased,
        timeBasedStart: start,
        timeBasedEnd: end,
        isCompleted: false,
        isPostponed: false,
        isDropped: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await dataSource.insertTask(task);
      final retrieved = await dataSource.getTaskById('time-based-task');

      expect(retrieved!.timeBasedStart, isNotNull);
      expect(retrieved.timeBasedEnd, isNotNull);
      expect(retrieved.timeBasedStart!.hour, start.hour);
      expect(retrieved.timeBasedStart!.minute, start.minute);
      expect(retrieved.timeBasedEnd!.hour, end.hour);
      expect(retrieved.timeBasedEnd!.minute, end.minute);
    });

    test('updateTask does not corrupt existing data', () async {
      // Insert task with all fields
      final original = TaskEntity(
        id: 'comprehensive-task',
        title: 'Original Title',
        description: 'Original Description',
        taskType: TaskType.deadline,
        deadline: DateTime(2024, 12, 31, 23, 59),
        isCompleted: false,
        isPostponed: false,
        isDropped: false,
        createdAt: DateTime(2024, 1, 1, 10, 0),
        updatedAt: DateTime(2024, 1, 1, 10, 0),
      );

      await dataSource.insertTask(original);

      // Update only the title
      final updated = original.copyWith(
        title: 'Updated Title',
        updatedAt: DateTime.now(),
      );

      await dataSource.updateTask(updated);
      final retrieved = await dataSource.getTaskById('comprehensive-task');

      // Verify title changed
      expect(retrieved!.title, 'Updated Title');

      // Verify other fields unchanged
      expect(retrieved.description, 'Original Description');
      expect(retrieved.taskType, TaskType.deadline);
      expect(retrieved.deadline, isNotNull);
      expect(retrieved.isCompleted, false);
      expect(retrieved.createdAt.year, 2024);
      expect(retrieved.createdAt.month, 1);
      expect(retrieved.createdAt.day, 1);
    });
  });
}
