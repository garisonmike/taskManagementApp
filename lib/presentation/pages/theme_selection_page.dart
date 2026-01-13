import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../providers/theme_provider.dart';

/// Theme selection page
class ThemeSelectionPage extends ConsumerWidget {
  const ThemeSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeNotifierProvider);
    final currentTheme = themeState.currentTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Select Theme')),
      body: ListView(
        children: [
          _buildThemeTile(
            context: context,
            ref: ref,
            themeMode: AppThemeMode.timberBrownLight,
            currentTheme: currentTheme,
            icon: Icons.wb_sunny_outlined,
          ),
          const Divider(height: 1),
          _buildThemeTile(
            context: context,
            ref: ref,
            themeMode: AppThemeMode.timberBrownDark,
            currentTheme: currentTheme,
            icon: Icons.nightlight_outlined,
          ),
          const Divider(height: 1),
          _buildThemeTile(
            context: context,
            ref: ref,
            themeMode: AppThemeMode.light,
            currentTheme: currentTheme,
            icon: Icons.light_mode_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeTile({
    required BuildContext context,
    required WidgetRef ref,
    required AppThemeMode themeMode,
    required AppThemeMode currentTheme,
    required IconData icon,
  }) {
    final isSelected = themeMode == currentTheme;

    return ListTile(
      leading: Icon(icon),
      title: Text(AppTheme.getThemeName(themeMode)),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            )
          : const Icon(Icons.circle_outlined),
      onTap: () async {
        await ref.read(themeNotifierProvider.notifier).changeTheme(themeMode);
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
    );
  }
}
