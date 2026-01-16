import '../../domain/entities/app_settings_entity.dart';
import '../datasources/local/app_settings_local_data_source.dart';
import '../models/app_settings_model.dart';

class AppSettingsRepository {
  final AppSettingsLocalDataSource _dataSource;

  AppSettingsRepository(this._dataSource);

  Future<AppSettingsEntity> getSettings() async {
    await _dataSource.initializeDefaultSettings();
    final model = await _dataSource.getSettings();
    return model!.toEntity();
  }

  Future<void> updateSettings(AppSettingsEntity settings) async {
    final model = AppSettingsModel.fromEntity(settings);
    await _dataSource.saveSettings(model);
  }

  Future<void> updatePreset(SettingsPreset preset) async {
    final current = await getSettings();
    final updated = current.copyWith(
      preset: preset,
      updatedAt: DateTime.now(),
    );
    await updateSettings(updated);
  }

  Future<void> toggleLogs(bool enabled) async {
    final current = await getSettings();
    final updated = current.copyWith(
      logsEnabled: enabled,
      updatedAt: DateTime.now(),
    );
    await updateSettings(updated);
  }

  Future<void> toggleGraphs(bool enabled) async {
    final current = await getSettings();
    final updated = current.copyWith(
      graphsEnabled: enabled,
      updatedAt: DateTime.now(),
    );
    await updateSettings(updated);
  }

  Future<void> toggleMealsTracking(bool enabled) async {
    final current = await getSettings();
    final updated = current.copyWith(
      mealsTrackingEnabled: enabled,
      updatedAt: DateTime.now(),
    );
    await updateSettings(updated);
  }

  Future<void> toggleNotificationPrivacy(bool enabled) async {
    final current = await getSettings();
    final updated = current.copyWith(
      notificationPrivacyEnabled: enabled,
      updatedAt: DateTime.now(),
    );
    await updateSettings(updated);
  }

  Future<void> toggleTaskLogs(bool enabled) async {
    final current = await getSettings();
    final updated = current.copyWith(
      taskLogsEnabled: enabled,
      updatedAt: DateTime.now(),
    );
    await updateSettings(updated);
  }

  Future<void> toggleMealLogs(bool enabled) async {
    final current = await getSettings();
    final updated = current.copyWith(
      mealLogsEnabled: enabled,
      updatedAt: DateTime.now(),
    );
    await updateSettings(updated);
  }

  Future<void> toggleWeeklySummaries(bool enabled) async {
    final current = await getSettings();
    final updated = current.copyWith(
      weeklySummariesEnabled: enabled,
      updatedAt: DateTime.now(),
    );
    await updateSettings(updated);
  }

  Future<void> toggleHeatmap(bool enabled) async {
    final current = await getSettings();
    final updated = current.copyWith(
      heatmapVisible: enabled,
      updatedAt: DateTime.now(),
    );
    await updateSettings(updated);
  }
}
