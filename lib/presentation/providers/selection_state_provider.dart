import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State for managing task selection
class SelectionState {
  final Set<String> selectedTaskIds;
  final bool isSelectionMode;

  const SelectionState({
    this.selectedTaskIds = const {},
    this.isSelectionMode = false,
  });

  SelectionState copyWith({
    Set<String>? selectedTaskIds,
    bool? isSelectionMode,
  }) {
    return SelectionState(
      selectedTaskIds: selectedTaskIds ?? this.selectedTaskIds,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
    );
  }

  int get selectedCount => selectedTaskIds.length;

  bool isSelected(String taskId) => selectedTaskIds.contains(taskId);
}

/// Notifier for managing task selection state
class SelectionStateNotifier extends StateNotifier<SelectionState> {
  SelectionStateNotifier() : super(const SelectionState());

  /// Toggle selection mode on/off
  void toggleSelectionMode() {
    if (state.isSelectionMode) {
      // Exit selection mode and clear selections
      state = const SelectionState();
    } else {
      // Enter selection mode
      state = state.copyWith(isSelectionMode: true);
    }
  }

  /// Toggle selection for a specific task
  void toggleTaskSelection(String taskId) {
    final newSelected = Set<String>.from(state.selectedTaskIds);
    if (newSelected.contains(taskId)) {
      newSelected.remove(taskId);
    } else {
      newSelected.add(taskId);
    }
    state = state.copyWith(selectedTaskIds: newSelected);
  }

  /// Select all tasks
  void selectAll(List<String> taskIds) {
    state = state.copyWith(selectedTaskIds: Set<String>.from(taskIds));
  }

  /// Clear all selections
  void clearSelection() {
    state = state.copyWith(selectedTaskIds: {});
  }

  /// Exit selection mode and clear selections
  void exitSelectionMode() {
    state = const SelectionState();
  }
}

/// Provider for selection state
final selectionStateProvider =
    StateNotifierProvider<SelectionStateNotifier, SelectionState>((ref) {
      return SelectionStateNotifier();
    });
