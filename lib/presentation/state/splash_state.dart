import 'package:flutter/foundation.dart';

/// Represents the current state of the splash screen and app initialization
@immutable
class SplashState {
  final bool isInitialized;
  final bool hasMinTimeElapsed;
  final String selectedImage;

  const SplashState({
    required this.isInitialized,
    required this.hasMinTimeElapsed,
    required this.selectedImage,
  });

  /// Whether the splash screen can dismiss
  bool get canDismiss => isInitialized && hasMinTimeElapsed;

  SplashState copyWith({
    bool? isInitialized,
    bool? hasMinTimeElapsed,
    String? selectedImage,
  }) {
    return SplashState(
      isInitialized: isInitialized ?? this.isInitialized,
      hasMinTimeElapsed: hasMinTimeElapsed ?? this.hasMinTimeElapsed,
      selectedImage: selectedImage ?? this.selectedImage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SplashState &&
        other.isInitialized == isInitialized &&
        other.hasMinTimeElapsed == hasMinTimeElapsed &&
        other.selectedImage == selectedImage;
  }

  @override
  int get hashCode =>
      isInitialized.hashCode ^
      hasMinTimeElapsed.hashCode ^
      selectedImage.hashCode;
}
