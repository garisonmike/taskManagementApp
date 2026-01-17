import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../providers/theme_provider.dart';

/// Page to customize the app theme color
class ThemeCustomizationPage extends ConsumerStatefulWidget {
  const ThemeCustomizationPage({super.key});

  @override
  ConsumerState<ThemeCustomizationPage> createState() =>
      _ThemeCustomizationPageState();
}

class _ThemeCustomizationPageState
    extends ConsumerState<ThemeCustomizationPage> {
  Color _selectedColor = Colors.blue;

  final List<Color> _availableColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  @override
  void initState() {
    super.initState();
    final themeState = ref.read(themeNotifierProvider);
    if (themeState.currentTheme == AppThemeMode.custom &&
        themeState.customColor != null) {
      _selectedColor = themeState.customColor!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customize Theme')),
      body: Column(
        children: [
          // Preview Section
          Expanded(flex: 2, child: _buildPreview()),
          const Divider(height: 1),
          // Color Picker Section
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Color',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: _availableColors.length,
                      itemBuilder: (context, index) {
                        final color = _availableColors[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedColor = color;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: _selectedColor == color
                                  ? Border.all(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                      width: 3,
                                    )
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: _selectedColor == color
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        await ref
                            .read(themeNotifierProvider.notifier)
                            .setCustomColor(_selectedColor);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('Apply Theme'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    // Generate a temporary theme for preview
    final previewTheme = AppTheme.customTheme(_selectedColor);

    return Theme(
      data: previewTheme,
      child: Container(
        color: previewTheme.colorScheme.surface,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Theme Preview',
              style: TextStyle(
                color: previewTheme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: previewTheme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text('Task Completed'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(value: 0.7),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
