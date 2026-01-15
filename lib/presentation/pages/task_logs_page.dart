import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/task_log_entity.dart';
import '../providers/task_log_provider.dart';
import '../providers/task_provider.dart';

/// Page for viewing task logs with settings for bulk deletion
class TaskLogsPage extends ConsumerStatefulWidget {
  const TaskLogsPage({super.key});

  @override
  ConsumerState<TaskLogsPage> createState() => _TaskLogsPageState();
}

class _TaskLogsPageState extends ConsumerState<TaskLogsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Logs'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'delete_all') {
                await _showDeleteConfirmation(context);
              } else if (value == 'delete_old') {
                await _showDeleteOldLogsDialog(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete_old',
                child: Text('Delete Old Logs'),
              ),
              const PopupMenuItem(
                value: 'delete_all',
                child: Text('Delete All Logs'),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<TaskLogEntity>>(
        future: ref.read(taskLogRepositoryProvider).getAllLogs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final logs = snapshot.data ?? [];

          if (logs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No logs yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Group logs by date
          final groupedLogs = <DateTime, List<TaskLogEntity>>{};
          for (final log in logs) {
            final date = DateTime(
              log.timestamp.year,
              log.timestamp.month,
              log.timestamp.day,
            );
            groupedLogs.putIfAbsent(date, () => []).add(log);
          }

          final sortedDates = groupedLogs.keys.toList()
            ..sort((a, b) => b.compareTo(a));

          return ListView.builder(
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              final date = sortedDates[index];
              final logsForDate = groupedLogs[date]!
                ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _formatDate(date),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...logsForDate.map((log) => _buildLogTile(context, log)),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLogTile(BuildContext context, TaskLogEntity log) {
    return FutureBuilder(
      future: ref.read(taskNotifierProvider.notifier).getTaskById(log.taskId),
      builder: (context, taskSnapshot) {
        final taskTitle = taskSnapshot.data?.title ?? 'Unknown Task';

        return ListTile(
          leading: CircleAvatar(child: Icon(_getActionIcon(log.action))),
          title: Text(taskTitle),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_getActionText(log.action)),
              Text(
                DateFormat('HH:mm:ss').format(log.timestamp),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          trailing: log.metadata != null
              ? IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () => _showMetadata(context, log),
                )
              : null,
        );
      },
    );
  }

  IconData _getActionIcon(TaskLogAction action) {
    switch (action) {
      case TaskLogAction.created:
        return Icons.add_circle;
      case TaskLogAction.completed:
        return Icons.check_circle;
      case TaskLogAction.failed:
        return Icons.cancel;
      case TaskLogAction.postponed:
        return Icons.schedule;
      case TaskLogAction.dropped:
        return Icons.delete;
      case TaskLogAction.edited:
        return Icons.edit;
      case TaskLogAction.deleted:
        return Icons.remove_circle;
    }
  }

  String _getActionText(TaskLogAction action) {
    switch (action) {
      case TaskLogAction.created:
        return 'Created';
      case TaskLogAction.completed:
        return 'Completed';
      case TaskLogAction.failed:
        return 'Failed';
      case TaskLogAction.postponed:
        return 'Postponed';
      case TaskLogAction.dropped:
        return 'Dropped';
      case TaskLogAction.edited:
        return 'Edited';
      case TaskLogAction.deleted:
        return 'Deleted';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) {
      return 'Today';
    } else if (date == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('EEEE, MMM d').format(date);
    }
  }

  Future<void> _showMetadata(BuildContext context, TaskLogEntity log) async {
    if (log.metadata == null) return;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: log.metadata!.entries
              .map(
                (entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text('${entry.key}: ${entry.value}'),
                ),
              )
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Logs'),
        content: const Text(
          'Are you sure you want to delete all logs? This action cannot be undone.',
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

    if (confirmed == true && context.mounted) {
      await ref.read(taskLogRepositoryProvider).deleteAllLogs();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('All logs deleted')));
        setState(() {}); // Refresh the page
      }
    }
  }

  Future<void> _showDeleteOldLogsDialog(BuildContext context) async {
    int? days = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Old Logs'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Delete logs older than:'),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('7 days'),
              onTap: () => Navigator.of(context).pop(7),
            ),
            ListTile(
              title: const Text('30 days'),
              onTap: () => Navigator.of(context).pop(30),
            ),
            ListTile(
              title: const Text('90 days'),
              onTap: () => Navigator.of(context).pop(90),
            ),
          ],
        ),
      ),
    );

    if (days != null && context.mounted) {
      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      await ref
          .read(taskLogRepositoryProvider)
          .deleteLogsByDateRange(DateTime(2000, 1, 1), cutoffDate);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted logs older than $days days')),
        );
        setState(() {}); // Refresh the page
      }
    }
  }
}
