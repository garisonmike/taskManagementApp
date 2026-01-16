import '../../domain/entities/reminder_entity.dart';
import '../../domain/entities/task_entity.dart';
import '../services/notification_service.dart';

/// Service for scheduling task reminders as notifications
class ReminderScheduler {
  final NotificationService _notificationService;

  ReminderScheduler({NotificationService? notificationService})
    : _notificationService =
          notificationService ?? NotificationService.instance;

  /// Schedule a notification for a reminder
  Future<void> scheduleReminder({
    required ReminderEntity reminder,
    required TaskEntity task,
  }) async {
    if (!reminder.isEnabled) return;

    final now = DateTime.now();
    if (reminder.reminderTime.isBefore(now)) {
      // Don't schedule past reminders
      return;
    }

    await _notificationService.scheduleNotification(
      id: reminder.id.hashCode, // Convert string ID to int
      title: 'Task Reminder: ${task.title}',
      body: task.description ?? 'You have a task reminder',
      scheduledTime: reminder.reminderTime,
      priority: reminder.priority,
      payload: task.id, // Pass task ID for navigation
    );
  }

  /// Cancel a scheduled reminder
  Future<void> cancelReminder(ReminderEntity reminder) async {
    await _notificationService.cancelNotification(reminder.id.hashCode);
  }

  /// Reschedule all active reminders for a task
  Future<void> rescheduleTaskReminders({
    required List<ReminderEntity> reminders,
    required TaskEntity task,
  }) async {
    for (final reminder in reminders) {
      // Cancel existing
      await cancelReminder(reminder);

      // Reschedule if enabled and in future
      if (reminder.isEnabled && reminder.reminderTime.isAfter(DateTime.now())) {
        await scheduleReminder(reminder: reminder, task: task);
      }
    }
  }

  /// Cancel all reminders for a task
  Future<void> cancelTaskReminders(List<ReminderEntity> reminders) async {
    for (final reminder in reminders) {
      await cancelReminder(reminder);
    }
  }
}
