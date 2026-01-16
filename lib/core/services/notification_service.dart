import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/entities/reminder_entity.dart';

/// Service for managing local notifications
/// Handles notification scheduling, permissions, and lifecycle
class NotificationService {
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  NotificationService._internal();

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone database
    tz.initializeTimeZones();

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // Combined initialization settings
    const initSettings = InitializationSettings(android: androidSettings);

    // Initialize the plugin
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // TODO: Navigate to specific task when notification is tapped
    // This will be implemented when we have navigation handling
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Check if notification permissions are granted
  Future<bool> hasPermissions() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  /// Schedule a notification for a specific time
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required ReminderPriority priority,
    String? payload,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    // Check permissions
    final hasPermission = await hasPermissions();
    if (!hasPermission) {
      final granted = await requestPermissions();
      if (!granted) return;
    }

    // Create notification details based on priority
    final androidDetails = priority == ReminderPriority.urgent
        ? const AndroidNotificationDetails(
            'urgent_reminders',
            'Urgent Reminders',
            channelDescription: 'Urgent task reminders with sound',
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
          )
        : const AndroidNotificationDetails(
            'normal_reminders',
            'Normal Reminders',
            channelDescription: 'Normal task reminders (silent)',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            enableVibration: false,
            playSound: false,
          );

    final notificationDetails = NotificationDetails(android: androidDetails);

    // Schedule the notification
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Get all pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Show an immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    ReminderPriority priority = ReminderPriority.normal,
    String? payload,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    final androidDetails = priority == ReminderPriority.urgent
        ? const AndroidNotificationDetails(
            'urgent_reminders',
            'Urgent Reminders',
            channelDescription: 'Urgent task reminders with sound',
            importance: Importance.high,
            priority: Priority.high,
          )
        : const AndroidNotificationDetails(
            'normal_reminders',
            'Normal Reminders',
            channelDescription: 'Normal task reminders (silent)',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}
