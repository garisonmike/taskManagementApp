import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/csv_export_service.dart';
import '../../core/services/csv_import_service.dart';
import '../../data/repositories/export_import_repository.dart';
import 'app_settings_provider.dart';
import 'blueprint_provider.dart';
import 'task_log_provider.dart';
import 'task_provider.dart';

// CSV service providers
final csvExportServiceProvider = Provider<CsvExportService>((ref) {
  return CsvExportService();
});

final csvImportServiceProvider = Provider<CsvImportService>((ref) {
  return CsvImportService();
});

// Export/Import repository provider
final exportImportRepositoryProvider = Provider<ExportImportRepository>((ref) {
  return ExportImportRepository(
    ref.watch(taskRepositoryProvider),
    ref.watch(blueprintRepositoryProvider),
    ref.watch(taskLogRepositoryProvider),
    ref.watch(appSettingsRepositoryProvider),
    ref.watch(csvExportServiceProvider),
    ref.watch(csvImportServiceProvider),
  );
});

// Export tasks provider
final exportTasksProvider = FutureProvider<String>((ref) async {
  final repository = ref.watch(exportImportRepositoryProvider);
  return await repository.exportTasks();
});

// Export blueprints provider
final exportBlueprintsProvider = FutureProvider<String>((ref) async {
  final repository = ref.watch(exportImportRepositoryProvider);
  return await repository.exportBlueprints();
});

// Export task logs provider
final exportTaskLogsProvider = FutureProvider<String>((ref) async {
  final repository = ref.watch(exportImportRepositoryProvider);
  return await repository.exportTaskLogs();
});

// Export settings provider
final exportSettingsProvider = FutureProvider<String>((ref) async {
  final repository = ref.watch(exportImportRepositoryProvider);
  return await repository.exportSettings();
});
