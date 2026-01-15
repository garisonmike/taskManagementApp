import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management_app/core/services/alarm_service.dart';

/// Provider for the AlarmService
final alarmServiceProvider = Provider<AlarmService>((ref) {
  return AlarmService();
});
