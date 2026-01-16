import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../pages/app_shell.dart';
import '../providers/splash_provider.dart';

/// Custom splash screen that displays a random image during app initialization
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Start initialization asynchronously
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(splashProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final splashState = ref.watch(splashProvider);

    // Listen for when we can dismiss the splash
    ref.listen<bool>(splashProvider.select((state) => state.canDismiss), (
      _,
      canDismiss,
    ) {
      if (canDismiss) {
        _navigateToHome();
      }
    });

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: Colors.white),
        child: Image.asset(
          splashState.selectedImage,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback in case image fails to load
            return const Center(
              child: Icon(Icons.task_alt, size: 100, color: Color(0xFF6D4C41)),
            );
          },
        ),
      ),
    );
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const AppShell()));
  }
}
