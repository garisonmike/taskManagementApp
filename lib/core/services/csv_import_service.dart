import 'dart:convert';

import '../../domain/entities/app_settings_entity.dart';
import '../../domain/entities/blueprint_entity.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_log_entity.dart';

class CsvImportService {
  /// Import tasks from CSV format
  List<TaskEntity> importTasks(String csvContent) {
    final lines = const LineSplitter().convert(csvContent);
    if (lines.isEmpty) return [];

    final tasks = <TaskEntity>[];
    // Skip header (first line)
    for (var i = 1; i < lines.length; i++) {
      final values = _parseCsvLine(lines[i]);
      if (values.length >= 14) {
        tasks.add(
          TaskEntity(
            id: values[0],
            title: values[1],
            description: values[2].isEmpty ? null : values[2],
            taskType: _parseTaskType(values[3]),
            deadline: values[4].isEmpty
                ? null
                : DateTime.fromMillisecondsSinceEpoch(int.parse(values[4])),
            timeBasedStart: values[5].isEmpty
                ? null
                : DateTime.fromMillisecondsSinceEpoch(int.parse(values[5])),
            timeBasedEnd: values[6].isEmpty
                ? null
                : DateTime.fromMillisecondsSinceEpoch(int.parse(values[6])),
            isCompleted: values[7] == '1',
            completionDate: values[8].isEmpty
                ? null
                : DateTime.fromMillisecondsSinceEpoch(int.parse(values[8])),
            failureReason: values[9].isEmpty ? null : values[9],
            isPostponed: values[10] == '1',
            isDropped: values[11] == '1',
            createdAt: DateTime.fromMillisecondsSinceEpoch(
              int.parse(values[12]),
            ),
            updatedAt: DateTime.fromMillisecondsSinceEpoch(
              int.parse(values[13]),
            ),
          ),
        );
      }
    }

    return tasks;
  }

  /// Import blueprints from CSV format
  List<BlueprintEntity> importBlueprints(String csvContent) {
    final lines = const LineSplitter().convert(csvContent);
    if (lines.isEmpty) return [];

    final blueprints = <BlueprintEntity>[];
    // Skip header (first line)
    for (var i = 1; i < lines.length; i++) {
      final values = _parseCsvLine(lines[i]);
      if (values.length >= 6) {
        blueprints.add(
          BlueprintEntity(
            id: values[0],
            name: values[1],
            description: values[2].isEmpty ? null : values[2],
            isActive: values[3] == '1',
            createdAt: DateTime.fromMillisecondsSinceEpoch(
              int.parse(values[4]),
            ),
            updatedAt: DateTime.fromMillisecondsSinceEpoch(
              int.parse(values[5]),
            ),
          ),
        );
      }
    }

    return blueprints;
  }

  /// Import task logs from CSV format
  List<TaskLogEntity> importTaskLogs(String csvContent) {
    final lines = const LineSplitter().convert(csvContent);
    if (lines.isEmpty) return [];

    final logs = <TaskLogEntity>[];
    // Skip header (first line)
    for (var i = 1; i < lines.length; i++) {
      final values = _parseCsvLine(lines[i]);
      if (values.length >= 5) {
        logs.add(
          TaskLogEntity(
            id: values[0],
            taskId: values[1],
            action: _parseTaskLogAction(values[2]),
            timestamp: DateTime.fromMillisecondsSinceEpoch(
              int.parse(values[3]),
            ),
            metadata: values[4].isEmpty
                ? null
                : (jsonDecode(values[4]) as Map<String, dynamic>),
          ),
        );
      }
    }

    return logs;
  }

  /// Import settings from CSV format
  AppSettingsEntity? importSettings(String csvContent) {
    final lines = const LineSplitter().convert(csvContent);
    if (lines.length < 2) return null;

    final values = _parseCsvLine(lines[1]);
    if (values.length >= 10) {
      return AppSettingsEntity(
        preset: _parseSettingsPreset(values[0]),
        logsEnabled: values[1] == '1',
        graphsEnabled: values[2] == '1',
        mealsTrackingEnabled: values[3] == '1',
        notificationPrivacyEnabled: values[4] == '1',
        taskLogsEnabled: values[5] == '1',
        mealLogsEnabled: values[6] == '1',
        weeklySummariesEnabled: values[7] == '1',
        heatmapVisible: values[8] == '1',
        updatedAt: DateTime.fromMillisecondsSinceEpoch(int.parse(values[9])),
      );
    }

    return null;
  }

  /// Parse CSV line handling quoted values
  List<String> _parseCsvLine(String line) {
    final values = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final char = line[i];

      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          // Escaped quote
          buffer.write('"');
          i++;
        } else {
          // Toggle quote state
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        // End of field
        values.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }

    // Add last field
    values.add(buffer.toString());

    return values;
  }

  TaskType _parseTaskType(String type) {
    switch (type) {
      case 'unsure':
        return TaskType.unsure;
      case 'deadline':
        return TaskType.deadline;
      case 'timeBased':
        return TaskType.timeBased;
      default:
        return TaskType.unsure;
    }
  }

  TaskLogAction _parseTaskLogAction(String action) {
    switch (action) {
      case 'created':
        return TaskLogAction.created;
      case 'completed':
        return TaskLogAction.completed;
      case 'postponed':
        return TaskLogAction.postponed;
      case 'dropped':
        return TaskLogAction.dropped;
      case 'edited':
        return TaskLogAction.edited;
      case 'deleted':
        return TaskLogAction.deleted;
      default:
        return TaskLogAction.created;
    }
  }

  SettingsPreset _parseSettingsPreset(String preset) {
    switch (preset) {
      case 'simple':
        return SettingsPreset.simple;
      case 'advanced':
        return SettingsPreset.advanced;
      default:
        return SettingsPreset.simple;
    }
  }
}
