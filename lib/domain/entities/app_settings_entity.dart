enum SettingsPreset {
  simple,
  advanced;

  String get displayName {
    switch (this) {
      case SettingsPreset.simple:
        return 'Simple';
      case SettingsPreset.advanced:
        return 'Advanced';
    }
  }
}

class AppSettingsEntity {
  final int? id;
  final SettingsPreset preset;

  // Toggles
  final bool logsEnabled;
  final bool graphsEnabled;
  final bool mealsTrackingEnabled;
  final bool notificationPrivacyEnabled;

  // Advanced toggles (only visible in advanced mode)
  final bool taskLogsEnabled;
  final bool mealLogsEnabled;
  final bool weeklySummariesEnabled;
  final bool heatmapVisible;

  final DateTime updatedAt;

  const AppSettingsEntity({
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

  // Default settings for simple preset
  factory AppSettingsEntity.defaultSimple() {
    return AppSettingsEntity(
      preset: SettingsPreset.simple,
      logsEnabled: true,
      graphsEnabled: true,
      mealsTrackingEnabled: true,
      notificationPrivacyEnabled: false,
      taskLogsEnabled: true,
      mealLogsEnabled: true,
      weeklySummariesEnabled: true,
      heatmapVisible: true,
      updatedAt: DateTime.now(),
    );
  }

  AppSettingsEntity copyWith({
    int? id,
    SettingsPreset? preset,
    bool? logsEnabled,
    bool? graphsEnabled,
    bool? mealsTrackingEnabled,
    bool? notificationPrivacyEnabled,
    bool? taskLogsEnabled,
    bool? mealLogsEnabled,
    bool? weeklySummariesEnabled,
    bool? heatmapVisible,
    DateTime? updatedAt,
  }) {
    return AppSettingsEntity(
      id: id ?? this.id,
      preset: preset ?? this.preset,
      logsEnabled: logsEnabled ?? this.logsEnabled,
      graphsEnabled: graphsEnabled ?? this.graphsEnabled,
      mealsTrackingEnabled: mealsTrackingEnabled ?? this.mealsTrackingEnabled,
      notificationPrivacyEnabled:
          notificationPrivacyEnabled ?? this.notificationPrivacyEnabled,
      taskLogsEnabled: taskLogsEnabled ?? this.taskLogsEnabled,
      mealLogsEnabled: mealLogsEnabled ?? this.mealLogsEnabled,
      weeklySummariesEnabled:
          weeklySummariesEnabled ?? this.weeklySummariesEnabled,
      heatmapVisible: heatmapVisible ?? this.heatmapVisible,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
