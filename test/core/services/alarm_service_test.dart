import 'package:flutter_test/flutter_test.dart';
import 'package:task_management_app/core/services/alarm_service.dart';

void main() {
  group('AlarmService', () {
    test('should instantiate without errors', () {
      expect(() => AlarmService(), returnsNormally);
    });
  });
}
