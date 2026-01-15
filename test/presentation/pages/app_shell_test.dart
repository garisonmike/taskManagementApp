import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_management_app/domain/entities/task_entity.dart';
import 'package:task_management_app/domain/repositories/task_repository.dart';
import 'package:task_management_app/presentation/pages/app_shell.dart';
import 'package:task_management_app/presentation/providers/blueprint_provider.dart';
import 'package:task_management_app/presentation/providers/reminder_provider.dart';
import 'package:task_management_app/presentation/providers/task_provider.dart';

void main() {
  group('AppShell Navigation Tests', () {
    testWidgets('App shell renders with bottom navigation bar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Override taskNotifierProvider to provide empty task list
            taskNotifierProvider.overrideWith(
              (ref) => TaskNotifier(FakeTaskRepository()),
            ),
          ],
          child: const MaterialApp(home: AppShell()),
        ),
      );

      // Wait for async operations
      await tester.pump();

      // Verify bottom navigation bar exists
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // Verify bottom nav has 4 items
      final navBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(navBar.items.length, 4);
    });

    testWidgets('Default page is Tasks page', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskNotifierProvider.overrideWith(
              (ref) => TaskNotifier(FakeTaskRepository()),
            ),
          ],
          child: const MaterialApp(home: AppShell()),
        ),
      );

      // Wait for async loading to complete
      await tester.pump();
      await tester.pump();

      // Tasks page should be visible initially
      expect(find.text('No tasks yet'), findsOneWidget);
      expect(find.text('Tap + to add your first task'), findsOneWidget);
    });

    testWidgets('Navigation to Reminders page works', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskNotifierProvider.overrideWith(
              (ref) => TaskNotifier(FakeTaskRepository()),
            ),
            remindersByDateProvider.overrideWith((ref) async => {}),
          ],
          child: const MaterialApp(home: AppShell()),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on Reminders tab
      await tester.tap(find.text('Reminders'));
      await tester.pumpAndSettle();

      // Verify Reminders page is displayed
      expect(find.text('No reminders'), findsOneWidget);
      expect(find.text('Set reminders for your tasks'), findsOneWidget);
    });

    testWidgets('Navigation to Blueprints page works', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskNotifierProvider.overrideWith(
              (ref) => TaskNotifier(FakeTaskRepository()),
            ),
            blueprintsProvider.overrideWith((ref) async => []),
          ],
          child: const MaterialApp(home: AppShell()),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on Blueprints tab
      await tester.tap(find.text('Blueprints'));
      await tester.pumpAndSettle();

      // Verify Blueprints page is displayed
      expect(find.text('No blueprints'), findsOneWidget);
      expect(find.text('Create recurring task templates'), findsOneWidget);
    });

    testWidgets('Navigation to Settings page works', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskNotifierProvider.overrideWith(
              (ref) => TaskNotifier(FakeTaskRepository()),
            ),
          ],
          child: const MaterialApp(home: AppShell()),
        ),
      );
      await tester.pump();

      // Tap on Settings tab
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Verify Settings page is displayed
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);

      // Scroll down to see Export Data (it may be below the fold)
      await tester.drag(find.text('Theme'), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(find.text('Export Data'), findsOneWidget);
    });

    testWidgets('Navigation maintains state when switching tabs', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskNotifierProvider.overrideWith(
              (ref) => TaskNotifier(FakeTaskRepository()),
            ),
            remindersByDateProvider.overrideWith((ref) async => {}),
          ],
          child: const MaterialApp(home: AppShell()),
        ),
      );

      // Wait for async loading to complete
      await tester.pumpAndSettle();

      // Start on Tasks page
      expect(find.text('No tasks yet'), findsOneWidget);

      // Navigate to Reminders
      await tester.tap(find.text('Reminders'));
      await tester.pumpAndSettle();
      expect(find.text('No reminders'), findsOneWidget);

      // Navigate to Settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Theme'), findsOneWidget);

      // Navigate back to Tasks
      await tester.tap(find.text('Tasks'));
      await tester.pumpAndSettle();
      expect(find.text('No tasks yet'), findsOneWidget);
    });

    testWidgets('Active icons change when navigating', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskNotifierProvider.overrideWith(
              (ref) => TaskNotifier(FakeTaskRepository()),
            ),
          ],
          child: const MaterialApp(home: AppShell()),
        ),
      );
      await tester.pump();

      // Initially on Tasks (index 0)
      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNavBar.currentIndex, 0);

      // Tap Reminders
      await tester.tap(find.text('Reminders'));
      await tester.pump();

      final updatedNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(updatedNavBar.currentIndex, 1);
    });
  });
}

// Fake repository for testing
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
