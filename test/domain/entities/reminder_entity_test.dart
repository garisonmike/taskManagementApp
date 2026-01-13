import 'package:flutter_test/flutter_test.dart';
import 'package:task_management_app/data/models/reminder_model.dart';
import 'package:task_management_app/domain/entities/reminder_entity.dart';

void main() {
  group('Reminder Data Model Tests', () {
    test('ReminderEntity is immutable and supports all fields', () {
      final reminderTime = DateTime(2026, 1, 15, 9, 0);
      final createdAt = DateTime.now();

      final reminder = ReminderEntity(
        id: '1',
        taskId: 'task-123',
        reminderTime: reminderTime,
        isEnabled: true,
        createdAt: createdAt,
      );

      expect(reminder.id, '1');
      expect(reminder.taskId, 'task-123');
      expect(reminder.reminderTime, reminderTime);
      expect(reminder.isEnabled, true);
      expect(reminder.createdAt, createdAt);
    });

    test('ReminderEntity copyWith creates new instance', () {
      final original = ReminderEntity(
        id: '2',
        taskId: 'task-456',
        reminderTime: DateTime.now(),
        isEnabled: true,
        createdAt: DateTime.now(),
      );

      final modified = original.copyWith(isEnabled: false);

      expect(original.isEnabled, true);
      expect(modified.isEnabled, false);
      expect(original.id, modified.id);
    });

    test('ReminderModel converts to/from entity correctly', () {
      final reminderTime = DateTime.now().add(const Duration(hours: 2));
      final createdAt = DateTime.now();

      final entity = ReminderEntity(
        id: '3',
        taskId: 'task-789',
        reminderTime: reminderTime,
        isEnabled: true,
        createdAt: createdAt,
      );

      final model = ReminderModel.fromEntity(entity);
      final convertedEntity = model.toEntity();

      expect(convertedEntity.id, entity.id);
      expect(convertedEntity.taskId, entity.taskId);
      expect(convertedEntity.isEnabled, entity.isEnabled);
      // Compare timestamps (milliseconds since epoch)
      expect(
        convertedEntity.reminderTime.millisecondsSinceEpoch,
        entity.reminderTime.millisecondsSinceEpoch,
      );
    });

    test('ReminderModel converts to/from database map correctly', () {
      final now = DateTime.now();
      final model = ReminderModel(
        id: '4',
        taskId: 'task-101',
        reminderTime: now.add(const Duration(days: 1)).millisecondsSinceEpoch,
        isEnabled: 1,
        createdAt: now.millisecondsSinceEpoch,
      );

      final map = model.toMap();
      final convertedModel = ReminderModel.fromMap(map);

      expect(convertedModel.id, model.id);
      expect(convertedModel.taskId, model.taskId);
      expect(convertedModel.reminderTime, model.reminderTime);
      expect(convertedModel.isEnabled, model.isEnabled);
      expect(convertedModel.createdAt, model.createdAt);
    });

    test('ReminderEntity equality works correctly', () {
      final time = DateTime.now();
      final reminder1 = ReminderEntity(
        id: '5',
        taskId: 'task-202',
        reminderTime: time,
        createdAt: time,
      );

      final reminder2 = ReminderEntity(
        id: '5',
        taskId: 'task-202',
        reminderTime: time,
        createdAt: time,
      );

      final reminder3 = ReminderEntity(
        id: '6',
        taskId: 'task-303',
        reminderTime: time,
        createdAt: time,
      );

      expect(reminder1, reminder2);
      expect(reminder1, isNot(reminder3));
    });

    test('ReminderEntity can be disabled', () {
      final reminder = ReminderEntity(
        id: '7',
        taskId: 'task-404',
        reminderTime: DateTime.now(),
        isEnabled: false,
        createdAt: DateTime.now(),
      );

      expect(reminder.isEnabled, false);
    });
  });
}
