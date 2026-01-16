import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/app_settings_local_data_source.dart';
import '../../data/datasources/local/database_helper.dart';
import '../../data/repositories/app_settings_repository.dart';
import '../../domain/entities/app_settings_entity.dart';
import '../state/app_settings_notifier.dart';

// Data source provider
final appSettingsLocalDataSourceProvider = Provider<AppSettingsLocalDataSource>(
  (ref) {
    return AppSettingsLocalDataSource(DatabaseHelper.instance);
  },
);

// Repository provider
final appSettingsRepositoryProvider = Provider<AppSettingsRepository>((ref) {
  return AppSettingsRepository(ref.watch(appSettingsLocalDataSourceProvider));
});

// Settings state notifier provider
final appSettingsNotifierProvider =
    StateNotifierProvider<AppSettingsNotifier, AsyncValue<AppSettingsEntity>>((
      ref,
    ) {
      return AppSettingsNotifier(ref.watch(appSettingsRepositoryProvider));
    });

// Convenience provider to get current settings
final appSettingsProvider = Provider<AppSettingsEntity?>((ref) {
  final asyncSettings = ref.watch(appSettingsNotifierProvider);
  return asyncSettings.when(
    data: (settings) => settings,
    loading: () => null,
    error: (_, __) => null,
  );
});
