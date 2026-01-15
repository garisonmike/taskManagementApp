import 'package:flutter_test/flutter_test.dart';
import 'package:task_management_app/domain/entities/blueprint_entity.dart';

void main() {
  group('BlueprintEntity', () {
    final now = DateTime.now();
    final blueprint = BlueprintEntity(
      id: 'test-id',
      name: 'Morning Routine',
      description: 'My daily morning tasks',
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    test('should create instance with required fields', () {
      expect(blueprint.id, 'test-id');
      expect(blueprint.name, 'Morning Routine');
      expect(blueprint.description, 'My daily morning tasks');
      expect(blueprint.isActive, true);
      expect(blueprint.createdAt, now);
      expect(blueprint.updatedAt, now);
    });

    test('should support copyWith', () {
      final updated = blueprint.copyWith(
        name: 'Evening Routine',
        isActive: false,
      );

      expect(updated.id, 'test-id');
      expect(updated.name, 'Evening Routine');
      expect(updated.description, 'My daily morning tasks');
      expect(updated.isActive, false);
      expect(updated.createdAt, now);
    });

    test('should support equality comparison', () {
      final blueprint2 = BlueprintEntity(
        id: 'test-id',
        name: 'Morning Routine',
        description: 'My daily morning tasks',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      expect(blueprint, equals(blueprint2));
    });

    test('should allow null description', () {
      final blueprintWithoutDesc = BlueprintEntity(
        id: 'test-id',
        name: 'Simple Routine',
        description: null,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      expect(blueprintWithoutDesc.description, isNull);
    });
  });
}
