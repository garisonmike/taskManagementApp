import 'package:flutter/material.dart';

/// Available theme modes for the app
enum AppThemeMode { timberBrownLight, timberBrownDark, light, custom }

/// Theme configuration for the Task Management App
class AppTheme {
  // Timber Brown color palette
  static const Color timberBrown = Color(0xFF6D4C41);
  static const Color timberBrownLight = Color(0xFF9C7A6A);
  static const Color timberBrownDark = Color(0xFF4B3529);
  static const Color timberBrownAccent = Color(0xFFA07D6C);

  /// Helper to get friendly name for theme mode
  static String getThemeName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.timberBrownLight:
        return 'Timber Brown (Light)';
      case AppThemeMode.timberBrownDark:
        return 'Timber Brown (Dark)';
      case AppThemeMode.light:
        return 'Standard Light';
      case AppThemeMode.custom:
        return 'Custom Theme';
    }
  }

  /// Timber Brown Light Theme (Default)
  static ThemeData get timberBrownLightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: timberBrown,
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: timberBrown,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: timberBrown,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: timberBrown,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  /// Timber Brown Dark Theme
  static ThemeData get timberBrownDarkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: timberBrown,
        brightness: Brightness.dark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: timberBrownDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: timberBrownLight,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: timberBrownAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  /// Standard Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  /// Custom Theme
  static ThemeData customTheme(Color seedColor) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: seedColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: seedColor,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: seedColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  /// Get theme data by mode
  static ThemeData getTheme(AppThemeMode mode, {Color? customColor}) {
    switch (mode) {
      case AppThemeMode.timberBrownLight:
        return timberBrownLightTheme;
      case AppThemeMode.timberBrownDark:
        return timberBrownDarkTheme;
      case AppThemeMode.light:
        return lightTheme;
      case AppThemeMode.custom:
        return customTheme(customColor ?? Colors.blue);
    }
  }
}
