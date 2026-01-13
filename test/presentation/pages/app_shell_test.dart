import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_management_app/presentation/pages/app_shell.dart';

void main() {
  group('AppShell Navigation Tests', () {
    testWidgets('App shell renders with bottom navigation bar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: AppShell())),
      );

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
        const ProviderScope(child: MaterialApp(home: AppShell())),
      );

      // Tasks page should be visible initially
      expect(find.text('No tasks yet'), findsOneWidget);
      expect(find.text('Tap + to add your first task'), findsOneWidget);
    });

    testWidgets('Navigation to Reminders page works', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: AppShell())),
      );

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
        const ProviderScope(child: MaterialApp(home: AppShell())),
      );

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
        const ProviderScope(child: MaterialApp(home: AppShell())),
      );

      // Tap on Settings tab
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Verify Settings page is displayed
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Export Data'), findsOneWidget);
    });

    testWidgets('Navigation maintains state when switching tabs', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: AppShell())),
      );

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
        const ProviderScope(child: MaterialApp(home: AppShell())),
      );

      // Initially on Tasks (index 0)
      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNavBar.currentIndex, 0);

      // Tap Reminders
      await tester.tap(find.text('Reminders'));
      await tester.pumpAndSettle();

      final updatedNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(updatedNavBar.currentIndex, 1);
    });
  });
}
