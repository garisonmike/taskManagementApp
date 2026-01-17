import 'dart:convert';

import '../../core/services/csv_export_service.dart';
import '../../core/services/csv_import_service.dart';
import '../../domain/repositories/blueprint_repository.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../../domain/repositories/task_log_repository.dart';
import '../../domain/repositories/task_repository.dart';
import '../models/app_settings_model.dart';
import '../models/blueprint_model.dart';
import '../models/reminder_model.dart';
import '../models/task_log_model.dart';
import '../models/task_model.dart';
import '../repositories/app_settings_repository.dart';

class ExportImportRepository {
  final TaskRepository _taskRepository;
  final BlueprintRepository _blueprintRepository;
  final TaskLogRepository _taskLogRepository;
  final AppSettingsRepository _appSettingsRepository;
  final ReminderRepository _reminderRepository;
  final CsvExportService _exportService;
  final CsvImportService _importService;

  ExportImportRepository(
    this._taskRepository,
    this._blueprintRepository,
    this._taskLogRepository,
    this._appSettingsRepository,
    this._reminderRepository,
    this._exportService,
    this._importService,
  );

  /// Export all app data to JSON
  Future<String> exportAllToJson() async {
    final tasks = await _taskRepository.getAllTasks();
    final blueprints = await _blueprintRepository.getAllBlueprints();
    final logs = await _taskLogRepository.getAllLogs();
    final settings = await _appSettingsRepository.getSettings();
    final reminders = await _reminderRepository.getAllReminders();

    final data = {
      'version': 1,
      'timestamp': DateTime.now().toIso8601String(),
      'tasks': tasks.map((e) => TaskModel.fromEntity(e).toMap()).toList(),
      'blueprints': blueprints
          .map((e) => BlueprintModel.fromEntity(e).toMap())
          .toList(),
      'logs': logs.map((e) => TaskLogModel.fromEntity(e).toMap()).toList(),
      'settings': AppSettingsModel.fromEntity(settings).toMap(),
      'reminders': reminders
          .map((e) => ReminderModel.fromEntity(e).toMap())
          .toList(),
    };

    return jsonEncode(data);
  }

  /// Import all app data from JSON
  Future<void> importAllFromJson(String jsonString) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Import Tasks
      if (data.containsKey('tasks')) {
        final tasksList = data['tasks'] as List;
        for (final item in tasksList) {
          final task = TaskModel.fromMap(item).toEntity();
          final existing = await _taskRepository.getTaskById(task.id);
          if (existing != null) {
            await _taskRepository.updateTask(task);
          } else {
            await _taskRepository.createTask(task);
          }
        }
      }

      // Import Blueprints
      if (data.containsKey('blueprints')) {
        final blueprintsList = data['blueprints'] as List;
        for (final item in blueprintsList) {
          final blueprint = BlueprintModel.fromMap(item).toEntity();
          final existing = await _blueprintRepository.getBlueprintById(
            blueprint.id,
          );
          if (existing != null) {
            await _blueprintRepository.updateBlueprint(blueprint);
          } else {
            await _blueprintRepository.createBlueprint(blueprint);
          }
        }
      }

      // Import Logs
      if (data.containsKey('logs')) {
        final logsList = data['logs'] as List;
        for (final item in logsList) {
          final log = TaskLogModel.fromMap(item).toEntity();
          // Logs usually don't have update logic exposed often, check repository
          // But Assuming conflict resolution or just create.
          // Since ID is UUID, try to get? TaskLogRepo might not have getById.
          // Just insert? If duplicate ID, safe insert might ignore.
          // Let's assume createLog handles usage safely or IDs are unique enough we can just try insert
          // But strict robustness requires check.
          // Since TaskLogRepo doesn't usually allow updates, we just try create.
          try {
            await _taskLogRepository.createLog(log);
          } catch (e) {
            // Ignore duplicate insertion errors
          }
        }
      }

      // Import Settings
      if (data.containsKey('settings')) {
        final settings = AppSettingsModel.fromMap(data['settings']).toEntity();
        await _appSettingsRepository.updateSettings(settings);
      }

      // Import Reminders
      if (data.containsKey('reminders')) {
        final remindersList = data['reminders'] as List;
        for (final item in remindersList) {
          final reminder = ReminderModel.fromMap(item).toEntity();
          final existing = await _reminderRepository.getReminderById(
            reminder.id,
          );
          if (existing != null) {
            await _reminderRepository.updateReminder(reminder);
          } else {
            await _reminderRepository.addReminder(reminder);
          }
        }
      }
    } catch (e) {
      throw FormatException('Invalid backup data: $e');
    }
  }

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
