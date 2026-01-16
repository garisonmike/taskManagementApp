import 'dart:convert';

import '../../domain/entities/app_settings_entity.dart';
import '../../domain/entities/blueprint_entity.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_log_entity.dart';

class CsvExportService {
  /// Export tasks to CSV format
  String exportTasks(List<TaskEntity> tasks) {
    final buffer = StringBuffer();

    // CSV header
    buffer.writeln(
      'id,title,description,task_type,deadline,time_based_start,time_based_end,is_completed,completion_date,failure_reason,is_postponed,is_dropped,created_at,updated_at',
    );

    // CSV rows
    for (final task in tasks) {
      buffer.writeln(
        [
          _escapeCsv(task.id),
          _escapeCsv(task.title),
          _escapeCsv(task.description ?? ''),
          _escapeCsv(task.taskType.name),
          task.deadline?.millisecondsSinceEpoch ?? '',
          task.timeBasedStart?.millisecondsSinceEpoch ?? '',
          task.timeBasedEnd?.millisecondsSinceEpoch ?? '',
          task.isCompleted ? '1' : '0',
          task.completionDate?.millisecondsSinceEpoch ?? '',
          _escapeCsv(task.failureReason ?? ''),
          task.isPostponed ? '1' : '0',
          task.isDropped ? '1' : '0',
          task.createdAt.millisecondsSinceEpoch,
          task.updatedAt.millisecondsSinceEpoch,
        ].join(','),
      );
    }

    return buffer.toString();
  }

  /// Export blueprints to CSV format
  String exportBlueprints(List<BlueprintEntity> blueprints) {
    final buffer = StringBuffer();

    // CSV header
    buffer.writeln('id,name,description,is_active,created_at,updated_at');

    // CSV rows
    for (final blueprint in blueprints) {
      buffer.writeln(
        [
          _escapeCsv(blueprint.id),
          _escapeCsv(blueprint.name),
          _escapeCsv(blueprint.description ?? ''),
          blueprint.isActive ? '1' : '0',
          blueprint.createdAt.millisecondsSinceEpoch,
          blueprint.updatedAt.millisecondsSinceEpoch,
        ].join(','),
      );
    }

    return buffer.toString();
  }

  /// Export task logs to CSV format
  String exportTaskLogs(List<TaskLogEntity> logs) {
    final buffer = StringBuffer();

    // CSV header
    buffer.writeln('id,task_id,action,timestamp,metadata');

    // CSV rows
    for (final log in logs) {
      buffer.writeln(
        [
          _escapeCsv(log.id),
          _escapeCsv(log.taskId),
          _escapeCsv(log.action.name),
          log.timestamp.millisecondsSinceEpoch.toString(),
          _escapeCsv(log.metadata != null ? jsonEncode(log.metadata) : ''),
        ].join(','),
      );
    }

    return buffer.toString();
  }

  /// Export settings to CSV format
  String exportSettings(AppSettingsEntity settings) {
    final buffer = StringBuffer();

    // CSV header
    buffer.writeln(
      'preset,logs_enabled,graphs_enabled,meals_tracking_enabled,notification_privacy_enabled,task_logs_enabled,meal_logs_enabled,weekly_summaries_enabled,heatmap_visible,updated_at',
    );

    // CSV row
    buffer.writeln(
      [
        _escapeCsv(settings.preset.name),
        settings.logsEnabled ? '1' : '0',
        settings.graphsEnabled ? '1' : '0',
        settings.mealsTrackingEnabled ? '1' : '0',
        settings.notificationPrivacyEnabled ? '1' : '0',
        settings.taskLogsEnabled ? '1' : '0',
        settings.mealLogsEnabled ? '1' : '0',
        settings.weeklySummariesEnabled ? '1' : '0',
        settings.heatmapVisible ? '1' : '0',
        settings.updatedAt.millisecondsSinceEpoch,
      ].join(','),
    );

    return buffer.toString();
  }

  /// Escape CSV values (handle commas, quotes, newlines)
  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
