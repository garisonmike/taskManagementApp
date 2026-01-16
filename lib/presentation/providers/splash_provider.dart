import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/splash_notifier.dart';
import '../state/splash_state.dart';

/// Provider for splash screen state
final splashProvider = StateNotifierProvider<SplashNotifier, SplashState>(
  (ref) => SplashNotifier(),
);
