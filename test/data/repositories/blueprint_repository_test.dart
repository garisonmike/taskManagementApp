import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:task_management_app/data/datasources/local/blueprint_local_data_source.dart';
import 'package:task_management_app/data/datasources/local/blueprint_task_local_data_source.dart';
import 'package:task_management_app/data/datasources/local/database_helper.dart';
import 'package:task_management_app/data/repositories/blueprint_repository_impl.dart';
import 'package:task_management_app/domain/entities/blueprint_entity.dart';
import 'package:task_management_app/domain/entities/blueprint_task_entity.dart';

void main() {
  late DatabaseHelper dbHelper;
  late BlueprintLocalDataSource blueprintDataSource;
  late BlueprintTaskLocalDataSource blueprintTaskDataSource;
  late BlueprintRepositoryImpl repository;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // Use unique database name for each test
    final testDbName =
        'test_blueprint_${DateTime.now().millisecondsSinceEpoch}.db';
    dbHelper = DatabaseHelper.test(testDbName);
    blueprintDataSource = BlueprintLocalDataSource(dbHelper);
    blueprintTaskDataSource = BlueprintTaskLocalDataSource(dbHelper);
    repository = BlueprintRepositoryImpl(
      blueprintDataSource,
      blueprintTaskDataSource,
    );
  });

  tearDown(() async {
    await dbHelper.close();
    await dbHelper.deleteDb();
  });

  group('BlueprintRepository', () {
    test('should create and retrieve blueprint', () async {
      final now = DateTime.now();
      final blueprint = BlueprintEntity(
        id: 'test-id',
        name: 'Morning Routine',
        description: 'My daily tasks',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      await repository.createBlueprint(blueprint);
      final retrieved = await repository.getBlueprintById('test-id');

      expect(retrieved, isNotNull);
      expect(retrieved!.id, 'test-id');
      expect(retrieved.name, 'Morning Routine');
      expect(retrieved.isActive, true);
    });

    test('should update blueprint', () async {
      final now = DateTime.now();
      final blueprint = BlueprintEntity(
        id: 'test-id',
        name: 'Morning Routine',
        description: 'My daily tasks',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      await repository.createBlueprint(blueprint);

      final updated = blueprint.copyWith(
        name: 'Evening Routine',
        isActive: false,
      );
      await repository.updateBlueprint(updated);

      final retrieved = await repository.getBlueprintById('test-id');
      expect(retrieved!.name, 'Evening Routine');
      expect(retrieved.isActive, false);
    });

    test('should delete blueprint and associated tasks', () async {
      final now = DateTime.now();
      final blueprint = BlueprintEntity(
        id: 'test-id',
        name: 'Test Blueprint',
        description: null,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      final task = BlueprintTaskEntity(
        id: 'task-id',
        blueprintId: 'test-id',
        title: 'Test Task',
        description: null,
        taskType: 'unsure',
        defaultTime: null,
        createdAt: now,
      );

      await repository.createBlueprint(blueprint);
      await repository.createBlueprintTask(task);

      await repository.deleteBlueprint('test-id');

      final retrieved = await repository.getBlueprintById('test-id');
      expect(retrieved, isNull);

      final tasks = await repository.getTasksByBlueprintId('test-id');
      expect(tasks, isEmpty);
    });

    test('should get all blueprints', () async {
      final now = DateTime.now();
      final blueprint1 = BlueprintEntity(
        id: 'id-1',
        name: 'Blueprint 1',
        description: null,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      final blueprint2 = BlueprintEntity(
        id: 'id-2',
        name: 'Blueprint 2',
        description: null,
        isActive: false,
        createdAt: now,
        updatedAt: now,
      );

      await repository.createBlueprint(blueprint1);
      await repository.createBlueprint(blueprint2);

      final all = await repository.getAllBlueprints();
      expect(all.length, 2);
    });

    test('should get only active blueprints', () async {
      final now = DateTime.now();
      final blueprint1 = BlueprintEntity(
        id: 'id-1',
        name: 'Blueprint 1',
        description: null,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      final blueprint2 = BlueprintEntity(
        id: 'id-2',
        name: 'Blueprint 2',
        description: null,
        isActive: false,
        createdAt: now,
        updatedAt: now,
      );

      await repository.createBlueprint(blueprint1);
      await repository.createBlueprint(blueprint2);

      final active = await repository.getActiveBlueprints();
      expect(active.length, 1);
      expect(active.first.id, 'id-1');
    });

    test('should create and retrieve blueprint tasks', () async {
      final now = DateTime.now();
      final blueprint = BlueprintEntity(
        id: 'blueprint-id',
        name: 'Test Blueprint',
        description: null,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      final task = BlueprintTaskEntity(
        id: 'task-id',
        blueprintId: 'blueprint-id',
        title: 'Morning Task',
        description: 'Do something',
        taskType: 'timeBased',
        defaultTime: '06:00',
        createdAt: now,
      );

      await repository.createBlueprint(blueprint);
      await repository.createBlueprintTask(task);

      final tasks = await repository.getTasksByBlueprintId('blueprint-id');
      expect(tasks.length, 1);
      expect(tasks.first.title, 'Morning Task');
    });

    test('should update blueprint task', () async {
      final now = DateTime.now();
      final blueprint = BlueprintEntity(
        id: 'blueprint-id',
        name: 'Test Blueprint',
        description: null,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      final task = BlueprintTaskEntity(
        id: 'task-id',
        blueprintId: 'blueprint-id',
        title: 'Morning Task',
        description: null,
        taskType: 'unsure',
        defaultTime: null,
        createdAt: now,
      );

      await repository.createBlueprint(blueprint);
      await repository.createBlueprintTask(task);

      final updated = task.copyWith(title: 'Evening Task');
      await repository.updateBlueprintTask(updated);

      final retrieved = await repository.getBlueprintTaskById('task-id');
      expect(retrieved!.title, 'Evening Task');
    });

    test('should delete blueprint task', () async {
      final now = DateTime.now();
      final blueprint = BlueprintEntity(
        id: 'blueprint-id',
        name: 'Test Blueprint',
        description: null,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      final task = BlueprintTaskEntity(
        id: 'task-id',
        blueprintId: 'blueprint-id',
        title: 'Test Task',
        description: null,
        taskType: 'unsure',
        defaultTime: null,
        createdAt: now,
      );

      await repository.createBlueprint(blueprint);
      await repository.createBlueprintTask(task);
      await repository.deleteBlueprintTask('task-id');

      final retrieved = await repository.getBlueprintTaskById('task-id');
      expect(retrieved, isNull);
    });
  });
}
