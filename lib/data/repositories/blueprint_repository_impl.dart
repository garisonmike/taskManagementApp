import '../../domain/entities/blueprint_entity.dart';
import '../../domain/entities/blueprint_task_entity.dart';
import '../../domain/repositories/blueprint_repository.dart';
import '../datasources/local/blueprint_local_data_source.dart';
import '../datasources/local/blueprint_task_local_data_source.dart';

/// Implementation of BlueprintRepository
///
/// This implementation ensures:
/// - Blueprints are stored independently from daily tasks
/// - Changes to blueprints only affect future task generation
/// - Custom daily tasks never modify the blueprint
class BlueprintRepositoryImpl implements BlueprintRepository {
  final BlueprintLocalDataSource _blueprintDataSource;
  final BlueprintTaskLocalDataSource _blueprintTaskDataSource;

  BlueprintRepositoryImpl(
    this._blueprintDataSource,
    this._blueprintTaskDataSource,
  );

  @override
  Future<List<BlueprintEntity>> getAllBlueprints() async {
    return await _blueprintDataSource.getAllBlueprints();
  }

  @override
  Future<List<BlueprintEntity>> getActiveBlueprints() async {
    return await _blueprintDataSource.getActiveBlueprints();
  }

  @override
  Future<BlueprintEntity?> getBlueprintById(String id) async {
    return await _blueprintDataSource.getBlueprintById(id);
  }

  @override
  Future<void> createBlueprint(BlueprintEntity blueprint) async {
    await _blueprintDataSource.createBlueprint(blueprint);
  }

  @override
  Future<void> updateBlueprint(BlueprintEntity blueprint) async {
    // Update blueprint with new timestamp
    final updatedBlueprint = blueprint.copyWith(updatedAt: DateTime.now());
    await _blueprintDataSource.updateBlueprint(updatedBlueprint);
  }

  @override
  Future<void> deleteBlueprint(String id) async {
    // First delete all associated blueprint tasks
    await _blueprintTaskDataSource.deleteTasksByBlueprintId(id);
    // Then delete the blueprint
    await _blueprintDataSource.deleteBlueprint(id);
  }

  @override
  Future<List<BlueprintTaskEntity>> getTasksByBlueprintId(
    String blueprintId,
  ) async {
    return await _blueprintTaskDataSource.getTasksByBlueprintId(blueprintId);
  }

  @override
  Future<BlueprintTaskEntity?> getBlueprintTaskById(String id) async {
    return await _blueprintTaskDataSource.getBlueprintTaskById(id);
  }

  @override
  Future<void> createBlueprintTask(BlueprintTaskEntity task) async {
    await _blueprintTaskDataSource.createBlueprintTask(task);
  }

  @override
  Future<void> updateBlueprintTask(BlueprintTaskEntity task) async {
    await _blueprintTaskDataSource.updateBlueprintTask(task);
  }

  @override
  Future<void> deleteBlueprintTask(String id) async {
    await _blueprintTaskDataSource.deleteBlueprintTask(id);
  }
}
