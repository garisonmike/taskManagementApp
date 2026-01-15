import 'package:flutter_test/flutter_test.dart';
import 'package:task_management_app/core/services/notification_service.dart';

/// NotificationService tests
///
/// Note: Most NotificationService functionality requires platform channels
/// which are not available in unit tests. These tests verify basic structure
/// and singleton pattern. Full notification functionality should be tested
/// with integration tests on actual devices/emulators.
void main() {
  group('NotificationService Tests', () {
    test('NotificationService is a singleton', () {
      final instance1 = NotificationService.instance;
      final instance2 = NotificationService.instance;
      expect(identical(instance1, instance2), true);
    });

    test('NotificationService instance is not null', () {
      final instance = NotificationService.instance;
      expect(instance, isNotNull);
    });
  });
}
