import 'package:flutter_test/flutter_test.dart';
import 'package:task_management_app/data/datasources/local/reminder_local_data_source.dart';
import 'package:task_management_app/data/repositories/reminder_repository_impl.dart';
import 'package:task_management_app/domain/entities/reminder_entity.dart';

void main() {
  group('ReminderRepository Tests', () {
    test('ReminderRepository can be instantiated', () {
      final repository = ReminderRepositoryImpl();
      expect(repository, isNotNull);
    });

    test('ReminderLocalDataSource can be instantiated', () {
      final dataSource = ReminderLocalDataSource();
      expect(dataSource, isNotNull);
    });

    test('ReminderEntity copyWith preserves unmodified fields', () {
      final now = DateTime.now();
      final reminder = ReminderEntity(
        id: 'test-id',
        taskId: 'task-id',
        reminderTime: now,
        isEnabled: true,
        createdAt: now,
      );

      final updated = reminder.copyWith(isEnabled: false);

      expect(updated.id, reminder.id);
      expect(updated.taskId, reminder.taskId);
      expect(updated.reminderTime, reminder.reminderTime);
      expect(updated.isEnabled, false);
      expect(updated.createdAt, reminder.createdAt);
    });

    test('ReminderEntity equality works correctly', () {
      final now = DateTime.now();
      final reminder1 = ReminderEntity(
        id: 'test-id',
        taskId: 'task-id',
        reminderTime: now,
        isEnabled: true,
        createdAt: now,
      );

      final reminder2 = ReminderEntity(
        id: 'test-id',
        taskId: 'task-id',
        reminderTime: now,
        isEnabled: true,
        createdAt: now,
      );

      expect(reminder1, equals(reminder2));
      expect(reminder1.hashCode, equals(reminder2.hashCode));
    });
  });
}
