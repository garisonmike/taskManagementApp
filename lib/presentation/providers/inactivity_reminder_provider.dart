import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/inactivity_reminder_service.dart';

/// Provider for inactivity reminder service
final inactivityReminderServiceProvider = Provider<InactivityReminderService>((
  ref,
) {
  return InactivityReminderService();
});

/// Provider for inactivity reminder enabled state
final inactivityReminderEnabledProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(inactivityReminderServiceProvider);
  return await service.isEnabled();
});

/// Provider for inactivity reminder time
final inactivityReminderTimeProvider = FutureProvider<String>((ref) async {
  final service = ref.watch(inactivityReminderServiceProvider);
  return await service.getReminderTime();
});
