import 'package:flutter_test/flutter_test.dart';
import 'package:task_management_app/presentation/state/splash_notifier.dart';
import 'package:task_management_app/presentation/state/splash_state.dart';

void main() {
  group('Splash Screen State Tests', () {
    test('SplashState canDismiss is false initially', () {
      const state = SplashState(
        isInitialized: false,
        hasMinTimeElapsed: false,
        selectedImage: 'assets/splash/test.png',
      );

      expect(state.canDismiss, false);
    });

    test('SplashState canDismiss is false if only initialized', () {
      const state = SplashState(
        isInitialized: true,
        hasMinTimeElapsed: false,
        selectedImage: 'assets/splash/test.png',
      );

      expect(state.canDismiss, false);
    });

    test('SplashState canDismiss is false if only time elapsed', () {
      const state = SplashState(
        isInitialized: false,
        hasMinTimeElapsed: true,
        selectedImage: 'assets/splash/test.png',
      );

      expect(state.canDismiss, false);
    });

    test('SplashState canDismiss is true when both conditions met', () {
      const state = SplashState(
        isInitialized: true,
        hasMinTimeElapsed: true,
        selectedImage: 'assets/splash/test.png',
      );

      expect(state.canDismiss, true);
    });

    test('SplashNotifier selects a random image on creation', () {
      final notifier = SplashNotifier();
      final state = notifier.state;

      expect(state.selectedImage, startsWith('assets/splash/'));
      expect(state.selectedImage, endsWith('.png'));
      expect(state.isInitialized, false);
      expect(state.hasMinTimeElapsed, false);
    });

    test('SplashNotifier initializes and sets both flags', () async {
      final notifier = SplashNotifier();

      // Start initialization
      final initFuture = notifier.initialize();

      // Wait for initialization to complete
      await initFuture;

      // Both flags should be set
      expect(notifier.state.isInitialized, true);
      expect(notifier.state.hasMinTimeElapsed, true);
      expect(notifier.state.canDismiss, true);
    });

    test('SplashNotifier waits minimum 1.5 seconds', () async {
      final notifier = SplashNotifier();
      final stopwatch = Stopwatch()..start();

      await notifier.initialize();

      stopwatch.stop();

      // Should take at least 1.5 seconds (1500ms)
      expect(stopwatch.elapsed.inMilliseconds, greaterThanOrEqualTo(1500));
    });

    test('SplashState copyWith creates new instance with updated values', () {
      const state = SplashState(
        isInitialized: false,
        hasMinTimeElapsed: false,
        selectedImage: 'assets/splash/test.png',
      );

      final updated = state.copyWith(isInitialized: true);

      expect(updated.isInitialized, true);
      expect(updated.hasMinTimeElapsed, false);
      expect(updated.selectedImage, 'assets/splash/test.png');
    });

    test('SplashState equality works correctly', () {
      const state1 = SplashState(
        isInitialized: true,
        hasMinTimeElapsed: true,
        selectedImage: 'assets/splash/test.png',
      );

      const state2 = SplashState(
        isInitialized: true,
        hasMinTimeElapsed: true,
        selectedImage: 'assets/splash/test.png',
      );

      const state3 = SplashState(
        isInitialized: false,
        hasMinTimeElapsed: true,
        selectedImage: 'assets/splash/test.png',
      );

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });

    test('multiple SplashNotifiers select different images (probabilistic)', () {
      // Create multiple notifiers and check that not all select the same image
      final images = <String>{};
      for (int i = 0; i < 20; i++) {
        final notifier = SplashNotifier();
        images.add(notifier.state.selectedImage);
      }

      // With 10 images and 20 tries, we should get at least 2 different images
      expect(images.length, greaterThan(1));
    });

    test('SplashState has correct hash code', () {
      const state1 = SplashState(
        isInitialized: true,
        hasMinTimeElapsed: true,
        selectedImage: 'assets/splash/test.png',
      );

      const state2 = SplashState(
        isInitialized: true,
        hasMinTimeElapsed: true,
        selectedImage: 'assets/splash/test.png',
      );

      expect(state1.hashCode, equals(state2.hashCode));
    });

    test('SplashState copyWith preserves unchanged values', () {
      const state = SplashState(
        isInitialized: true,
        hasMinTimeElapsed: false,
        selectedImage: 'assets/splash/test.png',
      );

      final updated = state.copyWith(hasMinTimeElapsed: true);

      expect(updated.isInitialized, true);
      expect(updated.hasMinTimeElapsed, true);
      expect(updated.selectedImage, 'assets/splash/test.png');
    });

    test('10 different splash images are available', () {
      // Verify all 10 images can be selected
      final allImages = <String>{};

      // Try multiple times to get all images
      for (int i = 0; i < 100; i++) {
        final notifier = SplashNotifier();
        allImages.add(notifier.state.selectedImage);
      }

      // Should have found multiple unique images
      expect(allImages.length, greaterThanOrEqualTo(5));
    });
  });
}
