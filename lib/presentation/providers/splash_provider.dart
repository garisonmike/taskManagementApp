import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/splash_notifier.dart';
import '../state/splash_state.dart';

/// Provider for the initial splash image selected
final initialSplashImageProvider = Provider<String>((ref) {
  throw UnimplementedError('initialSplashImageProvider must be overridden');
});

/// Provider for splash screen state
final splashProvider = StateNotifierProvider<SplashNotifier, SplashState>((
  ref,
) {
  final initialImage = ref.watch(initialSplashImageProvider);
  return SplashNotifier(initialImage);
});
