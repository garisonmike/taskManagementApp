import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/app_settings_repository.dart';
import '../../domain/entities/app_settings_entity.dart';

class AppSettingsNotifier extends StateNotifier<AsyncValue<AppSettingsEntity>> {
  final AppSettingsRepository _repository;

  AppSettingsNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    state = const AsyncValue.loading();
    try {
      final settings = await _repository.getSettings();
      state = AsyncValue.data(settings);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updatePreset(SettingsPreset preset) async {
    await _repository.updatePreset(preset);
    await _loadSettings();
  }

  Future<void> toggleLogs(bool enabled) async {
    await _repository.toggleLogs(enabled);
    await _loadSettings();
  }

  Future<void> toggleGraphs(bool enabled) async {
    await _repository.toggleGraphs(enabled);
    await _loadSettings();
  }

  Future<void> toggleMealsTracking(bool enabled) async {
    await _repository.toggleMealsTracking(enabled);
    await _loadSettings();
  }

  Future<void> toggleNotificationPrivacy(bool enabled) async {
    await _repository.toggleNotificationPrivacy(enabled);
    await _loadSettings();
  }

  Future<void> toggleTaskLogs(bool enabled) async {
    await _repository.toggleTaskLogs(enabled);
    await _loadSettings();
  }

  Future<void> toggleMealLogs(bool enabled) async {
    await _repository.toggleMealLogs(enabled);
    await _loadSettings();
  }

  Future<void> toggleWeeklySummaries(bool enabled) async {
    await _repository.toggleWeeklySummaries(enabled);
    await _loadSettings();
  }

  Future<void> toggleHeatmap(bool enabled) async {
    await _repository.toggleHeatmap(enabled);
    await _loadSettings();
  }
}
