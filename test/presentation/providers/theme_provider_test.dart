import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:task_management_app/core/theme/app_theme.dart';
import 'package:task_management_app/data/datasources/local/database_helper.dart';
import 'package:task_management_app/data/datasources/local/settings_local_data_source.dart';
import 'package:task_management_app/data/repositories/theme_repository_impl.dart';

void main() {
  late DatabaseHelper dbHelper;
  late SettingsLocalDataSource dataSource;
  late ThemeRepository repository;

  // Initialize FFI for testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    dbHelper = DatabaseHelper.instance;
    await dbHelper.deleteDb();
    dataSource = SettingsLocalDataSource(dbHelper);
    repository = ThemeRepository(dataSource);
  });

  tearDown(() async {
    await dbHelper.close();
  });

  group('Theme System Tests', () {
    test('Default theme is Timber Brown Light', () async {
      final theme = await repository.loadThemeMode();
      expect(theme, AppThemeMode.timberBrownLight);
    });

    test('Theme persists after saving', () async {
      // Save dark theme
      await repository.saveThemeMode(AppThemeMode.timberBrownDark);

      // Load it back
      final loaded = await repository.loadThemeMode();
      expect(loaded, AppThemeMode.timberBrownDark);
    });

    test(
      'Theme persists across repository recreations (simulating restart)',
      () async {
        // Save light theme
        await repository.saveThemeMode(AppThemeMode.light);

        // Create new repository (simulating app restart)
        final newRepository = ThemeRepository(dataSource);
        final loaded = await newRepository.loadThemeMode();

        expect(loaded, AppThemeMode.light);
      },
    );

    test('All three themes can be saved and loaded', () async {
      for (final theme in AppThemeMode.values) {
        await repository.saveThemeMode(theme);
        final loaded = await repository.loadThemeMode();
        expect(loaded, theme);
      }
    });

    test('Custom theme persists with color', () async {
      // Save custom theme and color
      await repository.saveThemeMode(AppThemeMode.custom);
      await repository.saveCustomColor(Colors.purple.value);

      // Load it back
      final loadedMode = await repository.loadThemeMode();
      final loadedColor = await repository.loadCustomColor();

      expect(loadedMode, AppThemeMode.custom);
      expect(loadedColor, Colors.purple.value);
    });

    test('Theme names are correct', () {
      expect(
        AppTheme.getThemeName(AppThemeMode.timberBrownLight),
        'Timber Brown (Light)',
      );
      expect(
        AppTheme.getThemeName(AppThemeMode.timberBrownDark),
        'Timber Brown (Dark)',
      );
      expect(AppTheme.getThemeName(AppThemeMode.light), 'Standard Light');
      expect(AppTheme.getThemeName(AppThemeMode.custom), 'Custom Theme');
    });

    test('Theme data is returned correctly', () {
      final lightTheme = AppTheme.getTheme(AppThemeMode.timberBrownLight);
      expect(lightTheme.brightness, Brightness.light);

      final darkTheme = AppTheme.getTheme(AppThemeMode.timberBrownDark);
      expect(darkTheme.brightness, Brightness.dark);

      final standardLightTheme = AppTheme.getTheme(AppThemeMode.light);
      expect(standardLightTheme.brightness, Brightness.light);

      final customTheme = AppTheme.getTheme(
        AppThemeMode.custom,
        customColor: Colors.purple,
      );

      // Verify that using a different color produces a different theme
      final redTheme = AppTheme.getTheme(
        AppThemeMode.custom,
        customColor: Colors.red,
      );

      expect(
        customTheme.colorScheme.primary,
        isNot(redTheme.colorScheme.primary),
        reason: 'Custom themes with different seed colors should differ',
      );

      // Verify it's not the default
      final defaultTheme = AppTheme.getTheme(AppThemeMode.timberBrownLight);
      expect(
        customTheme.colorScheme.primary,
        isNot(defaultTheme.colorScheme.primary),
      );
    });
  });
}
