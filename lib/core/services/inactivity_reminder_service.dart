import '../../data/datasources/local/database_helper.dart';
import '../../data/datasources/local/settings_local_data_source.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/repositories/task_repository.dart';
import 'notification_service.dart';

/// Service for managing inactivity reminder
/// Triggers a notification when no tasks exist
class InactivityReminderService {
  static const String _enabledKey = 'inactivity_reminder_enabled';
  static const String _timeKey = 'inactivity_reminder_time';
  static const String _defaultTime = '09:00'; // 9 AM default
  static const int _notificationId =
      999999; // Unique ID for inactivity reminder

  final SettingsLocalDataSource _settingsDataSource;
  final TaskRepository _taskRepository;
  final NotificationService _notificationService;

  InactivityReminderService({
    SettingsLocalDataSource? settingsDataSource,
    TaskRepository? taskRepository,
    NotificationService? notificationService,
  }) : _settingsDataSource =
           settingsDataSource ??
           SettingsLocalDataSource(DatabaseHelper.instance),
       _taskRepository = taskRepository ?? TaskRepositoryImpl(),
       _notificationService =
           notificationService ?? NotificationService.instance;

  /// Check if inactivity reminder is enabled
  Future<bool> isEnabled() async {
    final value = await _settingsDataSource.getSetting(_enabledKey);
    return value == 'true';
  }

  /// Enable or disable inactivity reminder
  Future<void> setEnabled(bool enabled) async {
    await _settingsDataSource.saveSetting(_enabledKey, enabled.toString());
    if (enabled) {
      await scheduleReminder();
    } else {
      await cancelReminder();
    }
  }

  /// Get configured reminder time (HH:mm format)
  Future<String> getReminderTime() async {
    final value = await _settingsDataSource.getSetting(_timeKey);
    return value ?? _defaultTime;
  }

  /// Set reminder time (HH:mm format)
  Future<void> setReminderTime(String time) async {
    await _settingsDataSource.saveSetting(_timeKey, time);
    final enabled = await isEnabled();
    if (enabled) {
      await scheduleReminder();
    }
  }

  /// Schedule the inactivity reminder
  Future<void> scheduleReminder() async {
    final enabled = await isEnabled();
    if (!enabled) return;

    // Check if there are any tasks
    final tasks = await _taskRepository.getAllTasks();
    if (tasks.isNotEmpty) {
      // Cancel reminder if tasks exist
      await cancelReminder();
      return;
    }

    // Get configured time
    final timeString = await getReminderTime();
    final timeParts = timeString.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    // Calculate next reminder time
    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);

    // If time has passed today, schedule for tomorrow
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    // Schedule notification
    await _notificationService.scheduleNotification(
      id: _notificationId,
      title: 'No tasks yet',
      body: 'Add some tasks to stay organized and productive!',
      scheduledTime: scheduledTime,
    );
  }

  /// Cancel the inactivity reminder
  Future<void> cancelReminder() async {
    await _notificationService.cancelNotification(_notificationId);
  }

  /// Check and update reminder based on task count
  /// Call this after adding or deleting tasks
  Future<void> updateReminderBasedOnTasks() async {
    final enabled = await isEnabled();
    if (!enabled) return;

    final tasks = await _taskRepository.getAllTasks();
    if (tasks.isEmpty) {
      // No tasks - schedule reminder
      await scheduleReminder();
    } else {
      // Tasks exist - cancel reminder
      await cancelReminder();
    }
  }
}
