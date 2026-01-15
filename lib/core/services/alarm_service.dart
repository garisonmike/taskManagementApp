import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Service to interact with Android's native alarm clock
///
/// This service allows users to create alarms using the system alarm clock app,
/// ensuring alarms persist even after app uninstall.
class AlarmService {
  static const MethodChannel _channel = MethodChannel(
    'task_management_app/alarm',
  );

  /// Opens the Android system alarm clock app to set a new alarm
  ///
  /// Parameters:
  /// - [hour]: Hour in 24-hour format (0-23)
  /// - [minute]: Minute (0-59)
  /// - [message]: Optional message/label for the alarm
  ///
  /// Returns true if the alarm intent was successfully launched
  Future<bool> setAlarm({
    required int hour,
    required int minute,
    String? message,
  }) async {
    try {
      final result = await _channel.invokeMethod<bool>('setAlarm', {
        'hour': hour,
        'minute': minute,
        'message': message ?? '',
      });
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to set alarm: ${e.message}');
      return false;
    }
  }

  /// Opens the Android system alarm clock app's main screen
  ///
  /// Returns true if the alarms list was successfully opened
  Future<bool> openAlarms() async {
    try {
      final result = await _channel.invokeMethod<bool>('openAlarms');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to open alarms: ${e.message}');
      return false;
    }
  }
}
