import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'splash_state.dart';

/// Manages splash screen state and initialization
class SplashNotifier extends StateNotifier<SplashState> {
  static const List<String> _splashImages = [
    'assets/splash/1percent.png',
    'assets/splash/Discipline.png',
    'assets/splash/RiskRich.png',
    'assets/splash/TrustInGod.png',
    'assets/splash/attributes.png',
    'assets/splash/donQuit.png',
    'assets/splash/justMoreFocus.png',
    'assets/splash/keepInMind.png',
    'assets/splash/stepByStep.png',
    'assets/splash/youCanDoIt.png',
  ];

  static const Duration _minDisplayTime = Duration(seconds: 2);

  SplashNotifier()
    : super(
        SplashState(
          isInitialized: false,
          hasMinTimeElapsed: false,
          selectedImage: _selectRandomImage(),
        ),
      );

  /// Randomly selects one splash image
  static String _selectRandomImage() {
    final random = Random();
    final index = random.nextInt(_splashImages.length);
    return _splashImages[index];
  }

  /// Initialize the app and enforce minimum display time
  Future<void> initialize() async {
    // Start minimum time timer
    final minTimeTask = Future.delayed(_minDisplayTime, () {
      if (!mounted) return;
      state = state.copyWith(hasMinTimeElapsed: true);
    });

    // Simulate app initialization (database, services, etc.)
    final initTask = _performInitialization();

    // Wait for both to complete
    await Future.wait([minTimeTask, initTask]);

    // Ensure both flags are set
    if (!mounted) return;
    state = state.copyWith(isInitialized: true, hasMinTimeElapsed: true);
  }

  /// Performs actual app initialization
  Future<void> _performInitialization() async {
    // This would include:
    // - Database initialization
    // - Loading user preferences
    // - Initializing services
    // - Preloading critical data

    // For now, we'll just add a small delay to simulate initialization
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;
    state = state.copyWith(isInitialized: true);
  }
}
