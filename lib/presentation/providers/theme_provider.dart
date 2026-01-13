import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/datasources/local/database_helper.dart';
import '../../data/datasources/local/settings_local_data_source.dart';
import '../../data/repositories/theme_repository_impl.dart';

/// State for theme management (immutable)
class ThemeState {
  final AppThemeMode currentTheme;
  final bool isLoading;

  const ThemeState({required this.currentTheme, this.isLoading = false});

  ThemeState copyWith({AppThemeMode? currentTheme, bool? isLoading}) {
    return ThemeState(
      currentTheme: currentTheme ?? this.currentTheme,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// StateNotifier for managing theme with persistence
class ThemeNotifier extends StateNotifier<ThemeState> {
  final ThemeRepository _repository;

  ThemeNotifier(this._repository)
    : super(const ThemeState(currentTheme: AppThemeMode.timberBrownLight)) {
    _loadTheme();
  }

  /// Load saved theme from storage
  Future<void> _loadTheme() async {
    state = state.copyWith(isLoading: true);
    try {
      final savedTheme = await _repository.loadThemeMode();
      state = state.copyWith(currentTheme: savedTheme, isLoading: false);
    } catch (e) {
      // If loading fails, use default
      state = state.copyWith(
        currentTheme: AppThemeMode.timberBrownLight,
        isLoading: false,
      );
    }
  }

  /// Change theme and persist to storage
  Future<void> changeTheme(AppThemeMode newTheme) async {
    state = state.copyWith(currentTheme: newTheme);
    await _repository.saveThemeMode(newTheme);
  }
}

/// Provider for ThemeRepository
final themeRepositoryProvider = Provider<ThemeRepository>((ref) {
  final dbHelper = DatabaseHelper.instance;
  final dataSource = SettingsLocalDataSource(dbHelper);
  return ThemeRepository(dataSource);
});

/// Provider for ThemeNotifier
final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((
  ref,
) {
  final repository = ref.watch(themeRepositoryProvider);
  return ThemeNotifier(repository);
});

/// Simple provider to get current theme mode
final currentThemeProvider = Provider<AppThemeMode>((ref) {
  return ref.watch(themeNotifierProvider).currentTheme;
});
