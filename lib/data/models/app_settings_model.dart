import '../../domain/entities/app_settings_entity.dart';

class AppSettingsModel {
  final int? id;
  final String preset;
  final bool logsEnabled;
  final bool graphsEnabled;
  final bool mealsTrackingEnabled;
  final bool notificationPrivacyEnabled;
  final bool taskLogsEnabled;
  final bool mealLogsEnabled;
  final bool weeklySummariesEnabled;
  final bool heatmapVisible;
  final DateTime updatedAt;

  const AppSettingsModel({
    this.id,
    required this.preset,
    required this.logsEnabled,
    required this.graphsEnabled,
    required this.mealsTrackingEnabled,
    required this.notificationPrivacyEnabled,
    required this.taskLogsEnabled,
    required this.mealLogsEnabled,
    required this.weeklySummariesEnabled,
    required this.heatmapVisible,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'preset': preset,
      'logs_enabled': logsEnabled ? 1 : 0,
      'graphs_enabled': graphsEnabled ? 1 : 0,
      'meals_tracking_enabled': mealsTrackingEnabled ? 1 : 0,
      'notification_privacy_enabled': notificationPrivacyEnabled ? 1 : 0,
      'task_logs_enabled': taskLogsEnabled ? 1 : 0,
      'meal_logs_enabled': mealLogsEnabled ? 1 : 0,
      'weekly_summaries_enabled': weeklySummariesEnabled ? 1 : 0,
      'heatmap_visible': heatmapVisible ? 1 : 0,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory AppSettingsModel.fromMap(Map<String, dynamic> map) {
    return AppSettingsModel(
      id: map['id'] as int?,
      preset: map['preset'] as String,
      logsEnabled: (map['logs_enabled'] as int) == 1,
      graphsEnabled: (map['graphs_enabled'] as int) == 1,
      mealsTrackingEnabled: (map['meals_tracking_enabled'] as int) == 1,
      notificationPrivacyEnabled:
          (map['notification_privacy_enabled'] as int) == 1,
      taskLogsEnabled: (map['task_logs_enabled'] as int) == 1,
      mealLogsEnabled: (map['meal_logs_enabled'] as int) == 1,
      weeklySummariesEnabled: (map['weekly_summaries_enabled'] as int) == 1,
      heatmapVisible: (map['heatmap_visible'] as int) == 1,
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  AppSettingsEntity toEntity() {
    return AppSettingsEntity(
      id: id,
      preset: _parsePreset(preset),
      logsEnabled: logsEnabled,
      graphsEnabled: graphsEnabled,
      mealsTrackingEnabled: mealsTrackingEnabled,
      notificationPrivacyEnabled: notificationPrivacyEnabled,
      taskLogsEnabled: taskLogsEnabled,
      mealLogsEnabled: mealLogsEnabled,
      weeklySummariesEnabled: weeklySummariesEnabled,
      heatmapVisible: heatmapVisible,
      updatedAt: updatedAt,
    );
  }

  factory AppSettingsModel.fromEntity(AppSettingsEntity entity) {
    return AppSettingsModel(
      id: entity.id,
      preset: entity.preset.name,
      logsEnabled: entity.logsEnabled,
      graphsEnabled: entity.graphsEnabled,
      mealsTrackingEnabled: entity.mealsTrackingEnabled,
      notificationPrivacyEnabled: entity.notificationPrivacyEnabled,
      taskLogsEnabled: entity.taskLogsEnabled,
      mealLogsEnabled: entity.mealLogsEnabled,
      weeklySummariesEnabled: entity.weeklySummariesEnabled,
      heatmapVisible: entity.heatmapVisible,
      updatedAt: entity.updatedAt,
    );
  }

  static SettingsPreset _parsePreset(String preset) {
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
