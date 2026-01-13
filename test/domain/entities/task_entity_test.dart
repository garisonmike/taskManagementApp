import 'package:flutter_test/flutter_test.dart';
import 'package:task_management_app/data/models/task_model.dart';
import 'package:task_management_app/domain/entities/task_entity.dart';

void main() {
  group('Task Data Model Tests', () {
    test('TaskEntity supports Unsure task type', () {
      final task = TaskEntity(
        id: '1',
        title: 'Unsure Task',
        taskType: TaskType.unsure,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(task.taskType, TaskType.unsure);
      expect(task.deadline, isNull);
      expect(task.timeBasedStart, isNull);
      expect(task.timeBasedEnd, isNull);
    });

    test('TaskEntity supports Deadline task type', () {
      final deadline = DateTime(2026, 1, 31, 23, 59);
      final task = TaskEntity(
        id: '2',
        title: 'Deadline Task',
        taskType: TaskType.deadline,
        deadline: deadline,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(task.taskType, TaskType.deadline);
      expect(task.deadline, deadline);
    });

    test('TaskEntity supports Time-based task type', () {
      final start = DateTime(2026, 1, 15, 9, 0);
      final end = DateTime(2026, 1, 15, 10, 30);
      final task = TaskEntity(
        id: '3',
        title: 'Time-based Task',
        taskType: TaskType.timeBased,
        timeBasedStart: start,
        timeBasedEnd: end,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(task.taskType, TaskType.timeBased);
      expect(task.timeBasedStart, start);
      expect(task.timeBasedEnd, end);
    });

    test('TaskEntity supports completion with optional failure reason', () {
      final completionDate = DateTime.now();
      final task = TaskEntity(
        id: '4',
        title: 'Completed Task',
        taskType: TaskType.unsure,
        isCompleted: true,
        completionDate: completionDate,
        failureReason: 'Could not complete on time',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(task.isCompleted, true);
      expect(task.completionDate, completionDate);
      expect(task.failureReason, 'Could not complete on time');
    });

    test('TaskEntity supports postpone state', () {
      final task = TaskEntity(
        id: '5',
        title: 'Postponed Task',
        taskType: TaskType.deadline,
        deadline: DateTime.now().add(const Duration(days: 1)),
        isPostponed: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(task.isPostponed, true);
    });

    test('TaskEntity supports drop state', () {
      final task = TaskEntity(
        id: '6',
        title: 'Dropped Task',
        taskType: TaskType.unsure,
        isDropped: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(task.isDropped, true);
    });

    test('TaskEntity is immutable - copyWith creates new instance', () {
      final original = TaskEntity(
        id: '7',
        title: 'Original',
        taskType: TaskType.unsure,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final modified = original.copyWith(title: 'Modified');

      expect(original.title, 'Original');
      expect(modified.title, 'Modified');
      expect(original.id, modified.id);
    });

    test('TaskModel converts to/from entity correctly', () {
      final now = DateTime.now();
      final entity = TaskEntity(
        id: '8',
        title: 'Test Task',
        description: 'Test Description',
        taskType: TaskType.deadline,
        deadline: now.add(const Duration(days: 7)),
        isCompleted: false,
        isPostponed: false,
        isDropped: false,
        createdAt: now,
        updatedAt: now,
      );

      final model = TaskModel.fromEntity(entity);
      final convertedEntity = model.toEntity();

      expect(convertedEntity.id, entity.id);
      expect(convertedEntity.title, entity.title);
      expect(convertedEntity.description, entity.description);
      expect(convertedEntity.taskType, entity.taskType);
      expect(convertedEntity.isCompleted, entity.isCompleted);
      expect(convertedEntity.isPostponed, entity.isPostponed);
      expect(convertedEntity.isDropped, entity.isDropped);
    });

    test('TaskModel converts to/from database map correctly', () {
      final now = DateTime.now();
      final model = TaskModel(
        id: '9',
        title: 'DB Task',
        description: 'DB Description',
        taskType: 'deadline',
        deadline: now.add(const Duration(days: 1)).millisecondsSinceEpoch,
        timeBasedStart: null,
        timeBasedEnd: null,
        isCompleted: 0,
        completionDate: null,
        failureReason: null,
        isPostponed: 0,
        isDropped: 0,
        createdAt: now.millisecondsSinceEpoch,
        updatedAt: now.millisecondsSinceEpoch,
      );

      final map = model.toMap();
      final convertedModel = TaskModel.fromMap(map);

      expect(convertedModel.id, model.id);
      expect(convertedModel.title, model.title);
      expect(convertedModel.description, model.description);
      expect(convertedModel.taskType, model.taskType);
      expect(convertedModel.deadline, model.deadline);
      expect(convertedModel.isCompleted, model.isCompleted);
    });

    test('TaskEntity equality works correctly', () {
      final now = DateTime.now();
      final task1 = TaskEntity(
        id: '10',
        title: 'Task',
        taskType: TaskType.unsure,
        createdAt: now,
        updatedAt: now,
      );

      final task2 = TaskEntity(
        id: '10',
        title: 'Task',
        taskType: TaskType.unsure,
        createdAt: now,
        updatedAt: now,
      );

      final task3 = TaskEntity(
        id: '11',
        title: 'Different Task',
        taskType: TaskType.unsure,
        createdAt: now,
        updatedAt: now,
      );

      expect(task1, task2);
      expect(task1, isNot(task3));
    });

    test('TaskEntity supports all required fields', () {
      final task = TaskEntity(
        id: '12',
        title: 'Full Task',
        description: 'Description',
        taskType: TaskType.timeBased,
        deadline: DateTime.now(),
        timeBasedStart: DateTime.now(),
        timeBasedEnd: DateTime.now().add(const Duration(hours: 1)),
        isCompleted: true,
        completionDate: DateTime.now(),
        failureReason: 'Test failure',
        isPostponed: true,
        isDropped: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Verify all fields are accessible
      expect(task.id, isNotEmpty);
      expect(task.title, isNotEmpty);
      expect(task.description, isNotNull);
      expect(task.taskType, isNotNull);
      expect(task.deadline, isNotNull);
      expect(task.timeBasedStart, isNotNull);
      expect(task.timeBasedEnd, isNotNull);
      expect(task.isCompleted, isNotNull);
      expect(task.completionDate, isNotNull);
      expect(task.failureReason, isNotNull);
      expect(task.isPostponed, isNotNull);
      expect(task.isDropped, isNotNull);
      expect(task.createdAt, isNotNull);
      expect(task.updatedAt, isNotNull);
    });
  });
}
