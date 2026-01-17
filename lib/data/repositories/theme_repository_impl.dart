import '../../core/theme/app_theme.dart';
import '../datasources/local/settings_local_data_source.dart';

/// Key for storing theme preference in local storage
const String _themeKey = 'app_theme_mode';
const String _customColorKey = 'app_theme_custom_color';

/// Repository for theme persistence
class ThemeRepository {
  final SettingsLocalDataSource _dataSource;

  ThemeRepository(this._dataSource);

  /// Save theme mode to local storage
  Future<void> saveThemeMode(AppThemeMode mode) async {
    await _dataSource.saveSetting('theme_mode', mode.name);
  }

  /// Load saved theme mode
  Future<AppThemeMode> loadThemeMode() async {
    final value = await _dataSource.getSetting('theme_mode');
    if (value == null) return AppThemeMode.timberBrownLight; // Default

    try {
      return AppThemeMode.values.firstWhere(
        (mode) => mode.name == value,
        orElse: () => AppThemeMode.timberBrownLight,
      );
    } catch (e) {
      return AppThemeMode.timberBrownLight;
    }
  }

  /// Save custom color
  Future<void> saveCustomColor(int colorValue) async {
    await _dataSource.saveSetting(_customColorKey, colorValue.toString());
  }

  /// Load custom color
  Future<int?> loadCustomColor() async {
    final value = await _dataSource.getSetting(_customColorKey);
    if (value == null) return null;
    return int.tryParse(value);
  }

  /// Save theme preference
  Future<void> saveTheme(AppThemeMode mode) async {
    await _dataSource.saveSetting(_themeKey, mode.name);
  }
}
