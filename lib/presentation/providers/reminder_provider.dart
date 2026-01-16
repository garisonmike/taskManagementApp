import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/reminder_repository_impl.dart';
import '../../domain/entities/reminder_entity.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/reminder_repository.dart';
import 'task_provider.dart';

/// Provider for reminder repository
final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  return ReminderRepositoryImpl();
});

/// Provider for reminders grouped by date
final remindersByDateProvider =
    FutureProvider<Map<DateTime, List<ReminderWithTask>>>((ref) async {
      final reminderRepo = ref.watch(reminderRepositoryProvider);
      final taskRepo = ref.watch(taskRepositoryProvider);

      final reminders = await reminderRepo.getAllReminders();
      final tasks = await taskRepo.getAllTasks();

      // Create a map of task ID to task
      final taskMap = {for (var task in tasks) task.id: task};

      // Group reminders by date (ignoring time)
      final groupedReminders = <DateTime, List<ReminderWithTask>>{};

      for (final reminder in reminders) {
        final date = DateTime(
          reminder.reminderTime.year,
          reminder.reminderTime.month,
          reminder.reminderTime.day,
        );

        final task = taskMap[reminder.taskId];
        if (task != null) {
          groupedReminders.putIfAbsent(date, () => []);
          groupedReminders[date]!.add(
            ReminderWithTask(reminder: reminder, task: task),
          );
        }
      }

      // Sort reminders within each day
      for (final reminders in groupedReminders.values) {
        reminders.sort(
          (a, b) => a.reminder.reminderTime.compareTo(b.reminder.reminderTime),
        );
      }

      return groupedReminders;
    });

/// Provider for all reminders with tasks (ungrouped, for history page)
final allRemindersWithTasksProvider = FutureProvider<List<ReminderWithTask>>((
  ref,
) async {
  final reminderRepo = ref.watch(reminderRepositoryProvider);
  final taskRepo = ref.watch(taskRepositoryProvider);

  final reminders = await reminderRepo.getAllReminders();
  final tasks = await taskRepo.getAllTasks();

  // Create a map of task ID to task
  final taskMap = {for (var task in tasks) task.id: task};

  // Create list of ReminderWithTask
  final result = <ReminderWithTask>[];
  for (final reminder in reminders) {
    final task = taskMap[reminder.taskId];
    if (task != null) {
      result.add(ReminderWithTask(reminder: reminder, task: task));
    }
  }

  return result;
});

/// Combined reminder and task data
class ReminderWithTask {
  final ReminderEntity reminder;
  final TaskEntity task;

  const ReminderWithTask({required this.reminder, required this.task});
}
