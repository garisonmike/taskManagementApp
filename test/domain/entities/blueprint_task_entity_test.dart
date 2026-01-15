import 'package:flutter_test/flutter_test.dart';
import 'package:task_management_app/domain/entities/blueprint_task_entity.dart';

void main() {
  group('BlueprintTaskEntity', () {
    final now = DateTime.now();
    final task = BlueprintTaskEntity(
      id: 'task-id',
      blueprintId: 'blueprint-id',
      title: 'Morning Exercise',
      description: '30 min workout',
      taskType: 'timeBased',
      defaultTime: '06:00',
      createdAt: now,
    );

    test('should create instance with required fields', () {
      expect(task.id, 'task-id');
      expect(task.blueprintId, 'blueprint-id');
      expect(task.title, 'Morning Exercise');
      expect(task.description, '30 min workout');
      expect(task.taskType, 'timeBased');
      expect(task.defaultTime, '06:00');
      expect(task.createdAt, now);
    });

    test('should support copyWith', () {
      final updated = task.copyWith(
        title: 'Evening Exercise',
        defaultTime: '18:00',
      );

      expect(updated.id, 'task-id');
      expect(updated.blueprintId, 'blueprint-id');
      expect(updated.title, 'Evening Exercise');
      expect(updated.description, '30 min workout');
      expect(updated.taskType, 'timeBased');
      expect(updated.defaultTime, '18:00');
    });

    test('should support equality comparison', () {
      final task2 = BlueprintTaskEntity(
        id: 'task-id',
        blueprintId: 'blueprint-id',
        title: 'Morning Exercise',
        description: '30 min workout',
        taskType: 'timeBased',
        defaultTime: '06:00',
        createdAt: now,
      );

      expect(task, equals(task2));
    });

    test('should allow null description and defaultTime', () {
      final simpleTask = BlueprintTaskEntity(
        id: 'task-id',
        blueprintId: 'blueprint-id',
        title: 'Simple Task',
        description: null,
        taskType: 'unsure',
        defaultTime: null,
        createdAt: now,
      );

      expect(simpleTask.description, isNull);
      expect(simpleTask.defaultTime, isNull);
    });
  });
}
