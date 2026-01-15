import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/services/reminder_scheduler.dart';
import '../providers/reminder_provider.dart';

/// Reminders page - View and manage reminders by day
class RemindersPage extends ConsumerWidget {
  const RemindersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsyncValue = ref.watch(remindersByDateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: remindersAsyncValue.when(
        data: (remindersByDate) {
          if (remindersByDate.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No reminders',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Set reminders for your tasks',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Sort dates
          final sortedDates = remindersByDate.keys.toList()
            ..sort((a, b) => a.compareTo(b));

          return ListView.builder(
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              final date = sortedDates[index];
              final reminders = remindersByDate[date]!;

              return _DateSection(date: date, reminders: reminders);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

/// Date section showing all reminders for a specific day
class _DateSection extends StatelessWidget {
  final DateTime date;
  final List<ReminderWithTask> reminders;

  const _DateSection({required this.date, required this.reminders});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    String dateLabel;
    if (date == today) {
      dateLabel = 'Today';
    } else if (date == tomorrow) {
      dateLabel = 'Tomorrow';
    } else {
      dateLabel = DateFormat('EEEE, MMM d').format(date);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            dateLabel,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...reminders.map(
          (reminderWithTask) =>
              _ReminderListTile(reminderWithTask: reminderWithTask),
        ),
        const Divider(height: 1),
      ],
    );
  }
}

/// Individual reminder list tile
class _ReminderListTile extends ConsumerWidget {
  final ReminderWithTask reminderWithTask;

  const _ReminderListTile({required this.reminderWithTask});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminder = reminderWithTask.reminder;
    final task = reminderWithTask.task;
    final timeFormat = DateFormat('h:mm a');

    return ListTile(
      leading: Icon(
        reminder.isEnabled
            ? Icons.notifications_active
            : Icons.notifications_off,
        color: reminder.isEnabled ? null : Colors.grey,
      ),
      title: Text(
        task.title,
        style: TextStyle(color: reminder.isEnabled ? null : Colors.grey),
      ),
      subtitle: Text(
        timeFormat.format(reminder.reminderTime),
        style: TextStyle(color: reminder.isEnabled ? null : Colors.grey),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            value: reminder.isEnabled,
            onChanged: (value) async {
              final updated = reminder.copyWith(isEnabled: value);
              await ref
                  .read(reminderRepositoryProvider)
                  .updateReminder(updated);

              // Update notification scheduling
              final scheduler = ReminderScheduler();
              if (value) {
                // Re-enable: schedule if in future
                if (reminder.reminderTime.isAfter(DateTime.now())) {
                  await scheduler.scheduleReminder(
                    reminder: updated,
                    task: task,
                  );
                }
              } else {
                // Disable: cancel notification
                await scheduler.cancelReminder(updated);
              }

              // Refresh the list
              ref.invalidate(remindersByDateProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showReminderMenu(context, ref),
          ),
        ],
      ),
    );
  }

  void _showReminderMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Time'),
              onTap: () async {
                Navigator.of(context).pop();
                await _showEditTimeDialog(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.of(context).pop();
                await _deleteReminder(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditTimeDialog(BuildContext context, WidgetRef ref) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        reminderWithTask.reminder.reminderTime,
      ),
    );

    if (pickedTime != null && context.mounted) {
      final pickedDate = await showDatePicker(
        context: context,
        initialDate: reminderWithTask.reminder.reminderTime,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      );

      if (pickedDate != null && context.mounted) {
        final newDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        final updated = reminderWithTask.reminder.copyWith(
          reminderTime: newDateTime,
        );

        await ref.read(reminderRepositoryProvider).updateReminder(updated);

        // Reschedule notification
        final scheduler = ReminderScheduler();
        await scheduler.cancelReminder(reminderWithTask.reminder);
        if (updated.isEnabled && newDateTime.isAfter(DateTime.now())) {
          await scheduler.scheduleReminder(
            reminder: updated,
            task: reminderWithTask.task,
          );
        }

        ref.invalidate(remindersByDateProvider);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reminder time updated')),
          );
        }
      }
    }
  }

  Future<void> _deleteReminder(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: const Text(
          'Are you sure you want to delete this reminder? The task will not be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      // Cancel notification
      final scheduler = ReminderScheduler();
      await scheduler.cancelReminder(reminderWithTask.reminder);

      // Delete from database
      await ref
          .read(reminderRepositoryProvider)
          .deleteReminder(reminderWithTask.reminder.id);

      ref.invalidate(remindersByDateProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Reminder deleted')));
      }
    }
  }
}
