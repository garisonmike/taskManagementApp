import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_management_app/data/datasources/local/settings_local_data_source.dart';
import 'package:task_management_app/domain/entities/task_entity.dart';
import 'package:task_management_app/domain/repositories/task_repository.dart';
import 'package:task_management_app/presentation/pages/app_shell.dart';
import 'package:task_management_app/presentation/providers/heatmap_provider.dart';
import 'package:task_management_app/presentation/providers/task_provider.dart';
import 'package:task_management_app/presentation/widgets/completion_heatmap.dart';

void main() {
  testWidgets('Heatmap appears at the bottom and opens dialog on tap', (
    WidgetTester tester,
  ) async {
    final heatmapNotifier = HeatmapVisibilityNotifierTest();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          taskNotifierProvider.overrideWith(
            (ref) => TaskNotifier(FakeTaskRepository()),
          ),
          heatmapVisibilityProvider.overrideWith((ref) => heatmapNotifier),
        ],
        child: const MaterialApp(home: AppShell()),
      ),
    );

    // Wait for async loading
    await tester.pumpAndSettle();

    // Verify Heatmap is present
    expect(find.byType(CompletionHeatmap), findsOneWidget);

    // Verify Order: Expanded/Center (Empty State) should be above 'Heatmap logic'
    // Since we are in the empty state (FakeTaskRepository returns []), we expect:
    // Column -> [Expanded -> Center, GestureDetector -> CompletionHeatmap]

    final columnFinder = find
        .descendant(of: find.byType(TasksPage), matching: find.byType(Column))
        .first; // The main column in the body

    final column = tester.widget<Column>(columnFinder);
    expect(column.children.length, 2);
    expect(column.children[0], isA<Expanded>()); // The content
    // The second child is the GestureDetector containing the heatmap (or conditional)
    // Actually, in the code:
    // if (heatmapVisibility.value == true) GestureDetector(...)
    // So the second child should be a GestureDetector

    // We can't easily assert types of children if they are implementation details like 'GestureDetector' unless we look for content.
    // But we know 'CompletionHeatmap' is the visual part.

    final centerFinder = find.text('No tasks yet');
    final heatmapFinder = find.byType(CompletionHeatmap);

    // Verify vertical position
    final centerBottom = tester.getBottomLeft(centerFinder).dy;
    final heatmapTop = tester.getTopLeft(heatmapFinder).dy;

    // The text 'No tasks yet' is inside the Expanded/Center.
    // The heatmap is at the bottom.
    // So centerBottom should be less than heatmapTop (y increases downwards)
    expect(
      centerBottom < heatmapTop,
      isTrue,
      reason: "Heatmap should be below the content",
    );

    // Test Interaction
    await tester.tap(find.byType(CompletionHeatmap));
    await tester.pumpAndSettle();

    // Verify Dialog
    expect(find.text('Heatmap Settings'), findsOneWidget);
    expect(find.text('Hide'), findsOneWidget);

    // Click Hide
    await tester.tap(find.text('Hide'));
    await tester.pumpAndSettle();

    // Verify visibility changed
    // Since HeatmapVisibilityNotifierTest is a real class (subclass), it should update state.
    // However, it uses FakeSettingsDataSource which doesn't persist to disk but might update state?
    // Let's check the test class logic below.
    // The real implementation of toggle calls toggle, set calls set.
    // We are using the real key logic just overriding the Data Source.

    // Check if heatmap is gone
    expect(find.byType(CompletionHeatmap), findsNothing);
  });
}

// Reuse Test Helpers
class HeatmapVisibilityNotifierTest extends HeatmapVisibilityNotifier {
  HeatmapVisibilityNotifierTest() : super(FakeSettingsDataSource()) {
    state = const AsyncValue.data(true);
  }
}

class FakeSettingsDataSource implements SettingsLocalDataSource {
  final Map<String, String> _storage = {};

  @override
  Future<void> saveSetting(String key, String value) async {
    _storage[key] = value;
  }

  @override
  Future<String?> getSetting(String key) async => _storage[key];

  @override
  Future<Map<String, String>> getAllSettings() async => _storage;

  @override
  Future<void> deleteSetting(String key) async {
    _storage.remove(key);
  }

  @override
  Future<void> clearAllSettings() async {
    _storage.clear();
  }
}

class FakeTaskRepository implements TaskRepository {
  @override
  Future<List<TaskEntity>> getAllTasks() async => [];
  @override
  Future<TaskEntity?> getTaskById(String id) async => null;
  @override
  Future<void> createTask(TaskEntity task) async {}
  @override
  Future<void> updateTask(TaskEntity task) async {}
  @override
  Future<void> deleteTask(String id) async {}
  @override
  Future<List<TaskEntity>> getTasksByStatus({
    required bool isCompleted,
  }) async => [];
  @override
  Future<List<TaskEntity>> getTasksByType(TaskType type) async => [];
}
