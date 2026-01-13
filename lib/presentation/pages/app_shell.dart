import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/task_entity.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import 'task_input_page.dart';
import 'theme_selection_page.dart';

/// Provider for managing the current navigation index
final navigationIndexProvider = StateProvider<int>((ref) => 0);

/// Main app shell with bottom navigation
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: const [
          TasksPage(),
          RemindersPage(),
          BlueprintsPage(),
          SettingsPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(navigationIndexProvider.notifier).state = index;
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            activeIcon: Icon(Icons.check_circle),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Reminders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.repeat_outlined),
            activeIcon: Icon(Icons.repeat),
            label: 'Blueprints',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

/// Tasks page - Main task list
class TasksPage extends ConsumerWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsyncValue = ref.watch(taskNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      body: tasksAsyncValue.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.task_alt, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No tasks yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap + to add your first task',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return TaskListTile(task: task);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading tasks',
                style: TextStyle(fontSize: 18, color: Colors.grey[800]),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(taskNotifierProvider.notifier).loadTasks();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<TaskEntity>(
            context,
            MaterialPageRoute(builder: (context) => const TaskInputPage()),
          );

          if (result != null && context.mounted) {
            await ref.read(taskNotifierProvider.notifier).addTask(result);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Task saved successfully')),
              );
            }
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Widget for displaying a single task in the list
class TaskListTile extends ConsumerWidget {
  final TaskEntity task;

  const TaskListTile({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Icon(
        _getTaskIcon(task.taskType),
        color: task.isCompleted ? Colors.green : null,
      ),
      title: Text(
        task.title,
        style: TextStyle(
          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: _buildSubtitle(),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (task.isCompleted)
            const Icon(Icons.check_circle, color: Colors.green)
          else
            IconButton(
              icon: const Icon(Icons.check_circle_outline),
              tooltip: 'Mark as complete',
              onPressed: () => _showCompleteTaskDialog(context, ref),
            ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            tooltip: 'More actions',
            onPressed: () => _showTaskActionsMenu(context, ref),
          ),
        ],
      ),
      onTap: () async {
        final result = await Navigator.push<TaskEntity>(
          context,
          MaterialPageRoute(
            builder: (context) => TaskInputPage(existingTask: task),
          ),
        );

        if (result != null && context.mounted) {
          await ref.read(taskNotifierProvider.notifier).updateTask(result);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Task updated successfully')),
            );
          }
        }
      },
    );
  }

  Future<void> _showCompleteTaskDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final shouldAddFailure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Task'),
        content: const Text('Did you complete this task successfully?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Failed'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Completed'),
          ),
        ],
      ),
    );

    if (shouldAddFailure == null) return;

    if (!context.mounted) return;

    if (shouldAddFailure) {
      // Complete successfully
      final updated = task.copyWith(
        isCompleted: true,
        completionDate: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await ref.read(taskNotifierProvider.notifier).updateTask(updated);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task marked as completed')),
        );
      }
    } else {
      // Failed - ask for reason
      if (!context.mounted) return;
      final reason = await _showFailureReasonDialog(context);
      if (reason != null && context.mounted) {
        final updated = task.copyWith(
          isCompleted: true,
          completionDate: DateTime.now(),
          failureReason: reason.isEmpty ? 'Failed' : reason,
          updatedAt: DateTime.now(),
        );
        await ref.read(taskNotifierProvider.notifier).updateTask(updated);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task marked as failed')),
          );
        }
      }
    }
  }

  Future<String?> _showFailureReasonDialog(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Failure Reason'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter reason (optional)',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  void _showTaskActionsMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!task.isCompleted)
              ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: const Text('Mark as Complete'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showCompleteTaskDialog(context, ref);
                },
              ),
            if (!task.isCompleted && task.taskType == TaskType.deadline)
              ListTile(
                leading: const Icon(Icons.schedule),
                title: const Text('Postpone'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showPostponeDialog(context, ref);
                },
              ),
            if (!task.isCompleted && task.taskType == TaskType.deadline)
              ListTile(
                leading: const Icon(Icons.event),
                title: const Text('Extend Deadline'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showExtendDeadlineDialog(context, ref);
                },
              ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () async {
                Navigator.of(context).pop();
                final result = await Navigator.push<TaskEntity>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskInputPage(existingTask: task),
                  ),
                );
                if (result != null && context.mounted) {
                  await ref
                      .read(taskNotifierProvider.notifier)
                      .updateTask(result);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Task updated successfully'),
                      ),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.of(context).pop();
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Task'),
                    content: const Text(
                      'Are you sure you want to delete this task?',
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
                  await ref
                      .read(taskNotifierProvider.notifier)
                      .deleteTask(task.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Task deleted')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPostponeDialog(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Postpone Task'),
        content: const Text('Mark this task as postponed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Postpone'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final updated = task.copyWith(
        isPostponed: true,
        updatedAt: DateTime.now(),
      );
      await ref.read(taskNotifierProvider.notifier).updateTask(updated);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Task postponed')));
      }
    }
  }

  Future<void> _showExtendDeadlineDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    if (task.deadline == null) return;

    final newDate = await showDatePicker(
      context: context,
      initialDate: task.deadline!.add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (newDate != null && context.mounted) {
      final newTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(task.deadline!),
      );

      if (newTime != null && context.mounted) {
        final newDeadline = DateTime(
          newDate.year,
          newDate.month,
          newDate.day,
          newTime.hour,
          newTime.minute,
        );

        final updated = task.copyWith(
          deadline: newDeadline,
          updatedAt: DateTime.now(),
        );
        await ref.read(taskNotifierProvider.notifier).updateTask(updated);
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Deadline extended')));
        }
      }
    }
  }

  Widget? _buildSubtitle() {
    final parts = <String>[];

    if (task.description != null && task.description!.isNotEmpty) {
      parts.add(task.description!);
    }

    if (task.taskType == TaskType.deadline && task.deadline != null) {
      parts.add('Deadline: ${_formatDateTime(task.deadline!)}');
    }

    if (task.taskType == TaskType.timeBased &&
        task.timeBasedStart != null &&
        task.timeBasedEnd != null) {
      parts.add(
        '${_formatDateTime(task.timeBasedStart!)} - ${_formatDateTime(task.timeBasedEnd!)}',
      );
    }

    if (parts.isEmpty) {
      return null;
    }

    return Text(parts.join('\n'), maxLines: 2, overflow: TextOverflow.ellipsis);
  }

  IconData _getTaskIcon(TaskType type) {
    switch (type) {
      case TaskType.unsure:
        return Icons.help_outline;
      case TaskType.deadline:
        return Icons.event;
      case TaskType.timeBased:
        return Icons.schedule;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

/// Reminders page - View and manage reminders
class RemindersPage extends StatelessWidget {
  const RemindersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: const Center(
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
      ),
    );
  }
}

/// Blueprints page - Manage recurring task templates
class BlueprintsPage extends StatelessWidget {
  const BlueprintsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blueprints')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.repeat, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No blueprints',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Create recurring task templates',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add blueprint
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Settings page - App configuration
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(currentThemeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Appearance',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Theme'),
            subtitle: Text(AppTheme.getThemeName(currentTheme)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ThemeSelectionPage(),
                ),
              );
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Data',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Export Data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Implement export
            },
          ),
          ListTile(
            leading: const Icon(Icons.upload_outlined),
            title: const Text('Import Data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Implement import
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'About',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outlined),
            title: const Text('Version'),
            subtitle: const Text('1.0.0'),
          ),
        ],
      ),
    );
  }
}
