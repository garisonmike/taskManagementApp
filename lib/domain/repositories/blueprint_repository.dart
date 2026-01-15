import '../entities/blueprint_entity.dart';
import '../entities/blueprint_task_entity.dart';

/// Repository interface for blueprint operations
///
/// This interface defines the contract for blueprint data access,
/// ensuring blueprints are stored independently from daily tasks.
abstract class BlueprintRepository {
  /// Get all blueprints
  Future<List<BlueprintEntity>> getAllBlueprints();

  /// Get active blueprints only
  Future<List<BlueprintEntity>> getActiveBlueprints();

  /// Get blueprint by ID
  Future<BlueprintEntity?> getBlueprintById(String id);

  /// Create a new blueprint
  Future<void> createBlueprint(BlueprintEntity blueprint);

  /// Update an existing blueprint
  Future<void> updateBlueprint(BlueprintEntity blueprint);

  /// Delete a blueprint
  Future<void> deleteBlueprint(String id);

  /// Get all tasks for a specific blueprint
  Future<List<BlueprintTaskEntity>> getTasksByBlueprintId(String blueprintId);

  /// Get blueprint task by ID
  Future<BlueprintTaskEntity?> getBlueprintTaskById(String id);

  /// Create a new blueprint task
  Future<void> createBlueprintTask(BlueprintTaskEntity task);

  /// Update an existing blueprint task
  Future<void> updateBlueprintTask(BlueprintTaskEntity task);

  /// Delete a blueprint task
  Future<void> deleteBlueprintTask(String id);
}
