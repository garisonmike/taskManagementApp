import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/local/database_helper.dart';
import 'data/datasources/local/settings_local_data_source.dart';
import 'presentation/providers/splash_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/state/splash_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service
  await NotificationService.instance.initialize();

  // Initialize settings to select splash image
  final dbHelper = DatabaseHelper.instance;
  final settingsSource = SettingsLocalDataSource(dbHelper);

  // Select random splash image avoiding the last one
  final lastSplash = await settingsSource.getSetting('last_splash_image');
  final images = SplashNotifier.splashImages;

  String selectedImage;
  if (images.isEmpty) {
    // Fallback should ideally be one of the known assets or a hardcoded failing path handled by error builder
    selectedImage = 'assets/splash/justMoreFocus.png';
  } else if (images.length == 1) {
    selectedImage = images.first;
  } else {
    final random = Random();
    List<String> validImages = images.toList();
    if (lastSplash != null) {
      validImages.remove(lastSplash);
      // Safety check: if removing lastSplash emptied the list (shouldn't happen with length > 1), revert
      if (validImages.isEmpty) {
        validImages = images.toList();
      }
    }
    selectedImage = validImages[random.nextInt(validImages.length)];
  }

  // Save selection for next time
  await settingsSource.saveSetting('last_splash_image', selectedImage);

  runApp(
    ProviderScope(
      overrides: [initialSplashImageProvider.overrideWithValue(selectedImage)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeNotifierProvider);

    return MaterialApp(
      title: 'Task Management App',
      theme: AppTheme.getTheme(
        themeState.currentTheme,
        customColor: themeState.customColor,
      ),
      home: const SplashScreen(),
    );
  }
}
