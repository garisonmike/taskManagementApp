import '../entities/reminder_entity.dart';

/// Repository interface for reminder operations
abstract class ReminderRepository {
  /// Get all reminders
  Future<List<ReminderEntity>> getAllReminders();

  /// Get reminders for a specific task
  Future<List<ReminderEntity>> getRemindersByTaskId(String taskId);

  /// Get reminders for a specific date range
  Future<List<ReminderEntity>> getRemindersByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get reminder by ID
  Future<ReminderEntity?> getReminderById(String id);

  /// Add a new reminder
  Future<void> addReminder(ReminderEntity reminder);

  /// Update an existing reminder
  Future<void> updateReminder(ReminderEntity reminder);

  /// Delete a reminder
  Future<void> deleteReminder(String id);

  /// Delete all reminders for a task
  Future<void> deleteRemindersByTaskId(String taskId);
}
