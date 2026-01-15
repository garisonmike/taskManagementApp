import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/database_helper.dart';
import '../../data/datasources/local/settings_local_data_source.dart';

/// Key for heatmap visibility setting
const String _heatmapVisibleKey = 'completion_heatmap_visible';

/// Provider for heatmap visibility setting
final heatmapVisibilityProvider =
    StateNotifierProvider<HeatmapVisibilityNotifier, AsyncValue<bool>>((ref) {
      final dbHelper = DatabaseHelper.instance;
      final dataSource = SettingsLocalDataSource(dbHelper);
      return HeatmapVisibilityNotifier(dataSource);
    });

/// State notifier for heatmap visibility
class HeatmapVisibilityNotifier extends StateNotifier<AsyncValue<bool>> {
  final SettingsLocalDataSource _dataSource;

  HeatmapVisibilityNotifier(this._dataSource)
    : super(const AsyncValue.loading()) {
    _loadVisibility();
  }

  /// Load visibility setting from database
  Future<void> _loadVisibility() async {
    try {
      final value = await _dataSource.getSetting(_heatmapVisibleKey);
      // Default to true (visible) if not set
      final isVisible = value == null ? true : value == 'true';
      state = AsyncValue.data(isVisible);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Set visibility setting
  Future<void> setVisibility(bool isVisible) async {
    try {
      await _dataSource.saveSetting(_heatmapVisibleKey, isVisible.toString());
      state = AsyncValue.data(isVisible);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Toggle visibility
  Future<void> toggleVisibility() async {
    final currentValue = state.value ?? true;
    await setVisibility(!currentValue);
  }
}
