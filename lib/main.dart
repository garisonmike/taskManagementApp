import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service
  await NotificationService.instance.initialize();

  runApp(const ProviderScope(child: MyApp()));
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
