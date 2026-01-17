import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../providers/theme_provider.dart';
import 'theme_customization_page.dart';

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
          const Divider(height: 1),
          _buildCustomThemeTile(
            context: context,
            ref: ref,
            currentTheme: currentTheme,
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

  Widget _buildCustomThemeTile({
    required BuildContext context,
    required WidgetRef ref,
    required AppThemeMode currentTheme,
  }) {
    final isSelected = currentTheme == AppThemeMode.custom;

    return ListTile(
      leading: const Icon(Icons.palette_outlined),
      title: const Text('Custom Theme'),
      subtitle: isSelected ? const Text('Tap edit to change color') : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelected)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ThemeCustomizationPage(),
                  ),
                );
              },
            ),
          if (isSelected)
            Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            )
          else
            const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
      onTap: () {
        if (isSelected) {
          // If already selected, maybe do nothing or open customize?
          // Let's open customize
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ThemeCustomizationPage(),
            ),
          );
        } else {
          // If not selected, open customize to pick a color first (or restore last if available?)
          // For now, always open customize to be safe
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ThemeCustomizationPage(),
            ),
          );
        }
      },
    );
  }
}
