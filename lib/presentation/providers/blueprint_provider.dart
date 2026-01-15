import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management_app/data/datasources/local/blueprint_local_data_source.dart';
import 'package:task_management_app/data/datasources/local/blueprint_task_local_data_source.dart';
import 'package:task_management_app/data/datasources/local/database_helper.dart';
import 'package:task_management_app/data/repositories/blueprint_repository_impl.dart';
import 'package:task_management_app/domain/entities/blueprint_entity.dart';
import 'package:task_management_app/domain/repositories/blueprint_repository.dart';

/// Provider for DatabaseHelper
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

/// Provider for BlueprintLocalDataSource
final blueprintLocalDataSourceProvider = Provider<BlueprintLocalDataSource>((
  ref,
) {
  return BlueprintLocalDataSource(ref.watch(databaseHelperProvider));
});

/// Provider for BlueprintTaskLocalDataSource
final blueprintTaskLocalDataSourceProvider =
    Provider<BlueprintTaskLocalDataSource>((ref) {
      return BlueprintTaskLocalDataSource(ref.watch(databaseHelperProvider));
    });

/// Provider for BlueprintRepository
final blueprintRepositoryProvider = Provider<BlueprintRepository>((ref) {
  return BlueprintRepositoryImpl(
    ref.watch(blueprintLocalDataSourceProvider),
    ref.watch(blueprintTaskLocalDataSourceProvider),
  );
});

/// Provider for all blueprints
final blueprintsProvider = FutureProvider<List<BlueprintEntity>>((ref) async {
  final repository = ref.watch(blueprintRepositoryProvider);
  return await repository.getAllBlueprints();
});

/// Provider for active blueprints only
final activeBlueprintsProvider = FutureProvider<List<BlueprintEntity>>((
  ref,
) async {
  final repository = ref.watch(blueprintRepositoryProvider);
  return await repository.getActiveBlueprints();
});
