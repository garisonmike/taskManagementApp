import '../../core/services/csv_export_service.dart';
import '../../core/services/csv_import_service.dart';
import '../../domain/repositories/blueprint_repository.dart';
import '../../domain/repositories/task_log_repository.dart';
import '../../domain/repositories/task_repository.dart';
import '../repositories/app_settings_repository.dart';

class ExportImportRepository {
  final TaskRepository _taskRepository;
  final BlueprintRepository _blueprintRepository;
  final TaskLogRepository _taskLogRepository;
  final AppSettingsRepository _appSettingsRepository;
  final CsvExportService _exportService;
  final CsvImportService _importService;

  ExportImportRepository(
    this._taskRepository,
    this._blueprintRepository,
    this._taskLogRepository,
    this._appSettingsRepository,
    this._exportService,
    this._importService,
  );

  /// Export all tasks to CSV
  Future<String> exportTasks() async {
    final tasks = await _taskRepository.getAllTasks();
    return _exportService.exportTasks(tasks);
  }

  /// Export all blueprints to CSV
  Future<String> exportBlueprints() async {
    final blueprints = await _blueprintRepository.getAllBlueprints();
    return _exportService.exportBlueprints(blueprints);
  }

  /// Export all task logs to CSV
  Future<String> exportTaskLogs() async {
    final logs = await _taskLogRepository.getAllLogs();
    return _exportService.exportTaskLogs(logs);
  }

  /// Export settings to CSV
  Future<String> exportSettings() async {
    final settings = await _appSettingsRepository.getSettings();
    return _exportService.exportSettings(settings);
  }

  /// Import tasks from CSV
  Future<void> importTasks(String csvContent) async {
    final tasks = _importService.importTasks(csvContent);
    for (final task in tasks) {
      await _taskRepository.createTask(task);
    }
  }

  /// Import blueprints from CSV
  Future<void> importBlueprints(String csvContent) async {
    final blueprints = _importService.importBlueprints(csvContent);
    for (final blueprint in blueprints) {
      await _blueprintRepository.createBlueprint(blueprint);
    }
  }

  /// Import task logs from CSV
  Future<void> importTaskLogs(String csvContent) async {
    final logs = _importService.importTaskLogs(csvContent);
    for (final log in logs) {
      await _taskLogRepository.createLog(log);
    }
  }

  /// Import settings from CSV
  Future<void> importSettings(String csvContent) async {
    final settings = _importService.importSettings(csvContent);
    if (settings != null) {
      await _appSettingsRepository.updateSettings(settings);
    }
  }
}
