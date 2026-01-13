import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:task_management_app/data/datasources/local/database_helper.dart';
import 'package:task_management_app/data/datasources/local/task_local_data_source.dart';
import 'package:task_management_app/data/repositories/task_repository_impl.dart';
import 'package:task_management_app/domain/entities/task_entity.dart';
import 'package:task_management_app/presentation/providers/task_provider.dart';

void main() {
  late ProviderContainer container;
  late DatabaseHelper databaseHelper;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() {
    databaseHelper = DatabaseHelper.test(inMemoryDatabasePath);
    final dataSource = TaskLocalDataSource(databaseHelper: databaseHelper);
    final repository = TaskRepositoryImpl(localDataSource: dataSource);

    container = ProviderContainer(
      overrides: [taskRepositoryProvider.overrideWithValue(repository)],
    );
  });

  tearDown(() async {
    await databaseHelper.close();
    container.dispose();
  });

  group('Task Completion Tests', () {
    test('Task can be marked as completed successfully', () async {
      final notifier = container.read(taskNotifierProvider.notifier);

      // Add a task
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
      await notifier.addTask(task);

      // Wait for state update
      await Future.delayed(const Duration(milliseconds: 100));

      // Mark as completed
      final completed = task.copyWith(
        isCompleted: true,
        completionDate: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await notifier.updateTask(completed);

      // Wait for state update
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify
      final state = container.read(taskNotifierProvider);
      state.when(
        data: (tasks) {
          expect(tasks.length, 1);
          expect(tasks.first.isCompleted, true);
          expect(tasks.first.completionDate, isNotNull);
        },
        loading: () => fail('Should not be loading'),
        error: (_, __) => fail('Should not be in error state'),
      );
    });

    test('Task can be marked as failed with reason', () async {
      final notifier = container.read(taskNotifierProvider.notifier);

      final task = TaskEntity(
        id: '2',
        title: 'Task to Fail',
        description: null,
        taskType: TaskType.deadline,
        deadline: DateTime.now().add(const Duration(days: 1)),
        isCompleted: false,
        isPostponed: false,
        isDropped: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await notifier.addTask(task);
      await Future.delayed(const Duration(milliseconds: 100));

      // Mark as failed with reason
      final failed = task.copyWith(
        isCompleted: true,
        completionDate: DateTime.now(),
        failureReason: 'Out of time',
        updatedAt: DateTime.now(),
      );
      await notifier.updateTask(failed);
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify
      final state = container.read(taskNotifierProvider);
      state.when(
        data: (tasks) {
          expect(tasks.length, 1);
          expect(tasks.first.isCompleted, true);
          expect(tasks.first.failureReason, 'Out of time');
        },
        loading: () => fail('Should not be loading'),
        error: (_, __) => fail('Should not be in error state'),
      );
    });

    test('Failure reason is optional', () async {
      final notifier = container.read(taskNotifierProvider.notifier);

      final task = TaskEntity(
        id: '3',
        title: 'Task with no failure reason',
        description: null,
        taskType: TaskType.unsure,
        isCompleted: false,
        isPostponed: false,
        isDropped: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await notifier.addTask(task);
      await Future.delayed(const Duration(milliseconds: 100));

      // Mark as failed without reason
      final failed = task.copyWith(
        isCompleted: true,
        completionDate: DateTime.now(),
        failureReason: null, // No reason
        updatedAt: DateTime.now(),
      );
      await notifier.updateTask(failed);
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify
      final state = container.read(taskNotifierProvider);
      state.when(
        data: (tasks) {
          expect(tasks.length, 1);
          expect(tasks.first.isCompleted, true);
          expect(tasks.first.failureReason, isNull);
        },
        loading: () => fail('Should not be loading'),
        error: (_, __) => fail('Should not be in error state'),
      );
    });
  });

  group('Task Postponement Tests', () {
    test('Task can be postponed', () async {
      final notifier = container.read(taskNotifierProvider.notifier);

      final task = TaskEntity(
        id: '4',
        title: 'Task to Postpone',
        description: null,
        taskType: TaskType.deadline,
        deadline: DateTime.now().add(const Duration(days: 1)),
        isCompleted: false,
        isPostponed: false,
        isDropped: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await notifier.addTask(task);
      await Future.delayed(const Duration(milliseconds: 100));

      // Postpone task
      final postponed = task.copyWith(
        isPostponed: true,
        updatedAt: DateTime.now(),
      );
      await notifier.updateTask(postponed);
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify
      final state = container.read(taskNotifierProvider);
      state.when(
        data: (tasks) {
          expect(tasks.length, 1);
          expect(tasks.first.isPostponed, true);
          expect(tasks.first.isCompleted, false); // Still not completed
        },
        loading: () => fail('Should not be loading'),
        error: (_, __) => fail('Should not be in error state'),
      );
    });
  });

  group('Deadline Extension Tests', () {
    test('Deadline can be extended', () async {
      final notifier = container.read(taskNotifierProvider.notifier);

      final originalDeadline = DateTime(2026, 1, 15, 10, 0);
      final task = TaskEntity(
        id: '5',
        title: 'Task with Deadline',
        description: null,
        taskType: TaskType.deadline,
        deadline: originalDeadline,
        isCompleted: false,
        isPostponed: false,
        isDropped: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await notifier.addTask(task);
      await Future.delayed(const Duration(milliseconds: 100));

      // Extend deadline
      final newDeadline = DateTime(2026, 1, 20, 10, 0);
      final extended = task.copyWith(
        deadline: newDeadline,
        updatedAt: DateTime.now(),
      );
      await notifier.updateTask(extended);
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify
      final state = container.read(taskNotifierProvider);
      state.when(
        data: (tasks) {
          expect(tasks.length, 1);
          expect(tasks.first.deadline, isNotNull);
          expect(tasks.first.deadline!.day, 20);
          expect(tasks.first.deadline!.isAfter(originalDeadline), true);
        },
        loading: () => fail('Should not be loading'),
        error: (_, __) => fail('Should not be in error state'),
      );
    });

    test('Deadline extension preserves other fields', () async {
      final notifier = container.read(taskNotifierProvider.notifier);

      final task = TaskEntity(
        id: '6',
        title: 'Comprehensive Task',
        description: 'Important task',
        taskType: TaskType.deadline,
        deadline: DateTime(2026, 1, 15, 10, 0),
        isCompleted: false,
        isPostponed: false,
        isDropped: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await notifier.addTask(task);
      await Future.delayed(const Duration(milliseconds: 100));

      // Extend deadline
      final extended = task.copyWith(
        deadline: DateTime(2026, 1, 25, 10, 0),
        updatedAt: DateTime.now(),
      );
      await notifier.updateTask(extended);
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify all fields preserved
      final state = container.read(taskNotifierProvider);
      state.when(
        data: (tasks) {
          expect(tasks.length, 1);
          final updated = tasks.first;
          expect(updated.title, 'Comprehensive Task');
          expect(updated.description, 'Important task');
          expect(updated.taskType, TaskType.deadline);
          expect(updated.isCompleted, false);
          expect(updated.isPostponed, false);
        },
        loading: () => fail('Should not be loading'),
        error: (_, __) => fail('Should not be in error state'),
      );
    });
  });

  group('Combined Operations Tests', () {
    test('Postponed task can still be completed', () async {
      final notifier = container.read(taskNotifierProvider.notifier);

      final task = TaskEntity(
        id: '7',
        title: 'Postponed then Completed',
        description: null,
        taskType: TaskType.unsure,
        isCompleted: false,
        isPostponed: false,
        isDropped: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await notifier.addTask(task);
      await Future.delayed(const Duration(milliseconds: 100));

      // First postpone
      final postponed = task.copyWith(
        isPostponed: true,
        updatedAt: DateTime.now(),
      );
      await notifier.updateTask(postponed);
      await Future.delayed(const Duration(milliseconds: 100));

      // Then complete
      final completed = postponed.copyWith(
        isCompleted: true,
        completionDate: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await notifier.updateTask(completed);
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify both flags are true
      final state = container.read(taskNotifierProvider);
      state.when(
        data: (tasks) {
          expect(tasks.length, 1);
          expect(tasks.first.isPostponed, true);
          expect(tasks.first.isCompleted, true);
        },
        loading: () => fail('Should not be loading'),
        error: (_, __) => fail('Should not be in error state'),
      );
    });

    test('Extended deadline task can be completed', () async {
      final notifier = container.read(taskNotifierProvider.notifier);

      final task = TaskEntity(
        id: '8',
        title: 'Extended then Completed',
        description: null,
        taskType: TaskType.deadline,
        deadline: DateTime(2026, 1, 15, 10, 0),
        isCompleted: false,
        isPostponed: false,
        isDropped: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await notifier.addTask(task);
      await Future.delayed(const Duration(milliseconds: 100));

      // Extend deadline
      final extended = task.copyWith(
        deadline: DateTime(2026, 1, 25, 10, 0),
        updatedAt: DateTime.now(),
      );
      await notifier.updateTask(extended);
      await Future.delayed(const Duration(milliseconds: 100));

      // Complete
      final completed = extended.copyWith(
        isCompleted: true,
        completionDate: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await notifier.updateTask(completed);
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify
      final state = container.read(taskNotifierProvider);
      state.when(
        data: (tasks) {
          expect(tasks.length, 1);
          expect(tasks.first.isCompleted, true);
          expect(tasks.first.deadline!.day, 25);
        },
        loading: () => fail('Should not be loading'),
        error: (_, __) => fail('Should not be in error state'),
      );
    });
  });
}
