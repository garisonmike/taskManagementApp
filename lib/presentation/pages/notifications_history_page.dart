import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/reminder_entity.dart';
import '../providers/reminder_provider.dart';

/// Notifications history page - Shows all reminders (past and future)
class NotificationsHistoryPage extends ConsumerWidget {
  const NotificationsHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsyncValue = ref.watch(allRemindersWithTasksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications History')),
      body: remindersAsyncValue.when(
        data: (reminders) {
          if (reminders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No notifications history',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your notification history will appear here',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Sort reminders by time (most recent first)
          final sortedReminders = List.from(reminders)
            ..sort(
              (a, b) =>
                  b.reminder.reminderTime.compareTo(a.reminder.reminderTime),
            );

          // Group by status: past, today, upcoming
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final tomorrow = today.add(const Duration(days: 1));

          final pastReminders = sortedReminders
              .where((r) => r.reminder.reminderTime.isBefore(today))
              .toList();
          final todayReminders = sortedReminders
              .where(
                (r) =>
                    r.reminder.reminderTime.isAfter(today) &&
                    r.reminder.reminderTime.isBefore(tomorrow),
              )
              .toList();
          final upcomingReminders = sortedReminders
              .where((r) => r.reminder.reminderTime.isAfter(tomorrow))
              .toList();

          return ListView(
            children: [
              if (todayReminders.isNotEmpty) ...[
                _SectionHeader(title: 'Today (${todayReminders.length})'),
                ...todayReminders.map(
                  (r) => _NotificationTile(reminderWithTask: r, isPast: false),
                ),
                const Divider(),
              ],
              if (upcomingReminders.isNotEmpty) ...[
                _SectionHeader(title: 'Upcoming (${upcomingReminders.length})'),
                ...upcomingReminders.map(
                  (r) => _NotificationTile(reminderWithTask: r, isPast: false),
                ),
                const Divider(),
              ],
              if (pastReminders.isNotEmpty) ...[
                _SectionHeader(title: 'Past (${pastReminders.length})'),
                ...pastReminders.map(
                  (r) => _NotificationTile(reminderWithTask: r, isPast: true),
                ),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

/// Section header widget
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}

/// Individual notification tile
class _NotificationTile extends StatelessWidget {
  final ReminderWithTask reminderWithTask;
  final bool isPast;

  const _NotificationTile({
    required this.reminderWithTask,
    required this.isPast,
  });

  @override
  Widget build(BuildContext context) {
    final reminder = reminderWithTask.reminder;
    final task = reminderWithTask.task;
    final dateTimeFormat = DateFormat('MMM d, y • h:mm a');
    final isUrgent = reminder.priority == ReminderPriority.urgent;

    return ListTile(
      leading: Icon(
        isPast ? Icons.history : Icons.schedule,
        color: isPast
            ? Colors.grey
            : (reminder.isEnabled
                  ? (isUrgent ? Colors.red : Colors.blue)
                  : Colors.grey),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              task.title,
              style: TextStyle(
                color: isPast || !reminder.isEnabled ? Colors.grey : null,
              ),
            ),
          ),
          if (isUrgent && reminder.isEnabled && !isPast) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red, width: 1),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.volume_up, size: 10, color: Colors.red),
                  SizedBox(width: 3),
                  Text(
                    'Urgent',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dateTimeFormat.format(reminder.reminderTime),
            style: TextStyle(
              color: isPast || !reminder.isEnabled ? Colors.grey : null,
            ),
          ),
          if (!reminder.isEnabled)
            const Text(
              'Disabled',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
      trailing: isPast
          ? Icon(
              Icons.check_circle_outline,
              color: Colors.grey.shade400,
              size: 20,
            )
          : null,
    );
  }
}
