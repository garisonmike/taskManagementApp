import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/utils/task_sorter.dart';
import '../providers/alarm_provider.dart';
import '../providers/blueprint_provider.dart';
import '../providers/heatmap_provider.dart';
import '../providers/inactivity_reminder_provider.dart';
import '../providers/reminder_provider.dart';
import '../providers/selection_state_provider.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/completion_heatmap.dart';
import 'blueprint_input_page.dart';
import 'reminders_page.dart';
import 'task_input_page.dart';
import 'task_logs_page.dart';
import 'theme_selection_page.dart';
import 'wellness_page.dart';

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
          WellnessPage(),
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
            icon: Icon(Icons.restaurant_menu),
            activeIcon: Icon(Icons.restaurant),
            label: 'Wellness',
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
    final tasksAsyncValue = ref.watch(sortedTasksProvider);
    final heatmapVisibility = ref.watch(heatmapVisibilityProvider);
    final selectionState = ref.watch(selectionStateProvider);
    final sortOrder = ref.watch(taskSortOrderProvider);

    return Scaffold(
      appBar: AppBar(
        title: selectionState.isSelectionMode
            ? Text('${selectionState.selectedCount} selected')
            : const Text('Tasks'),
        leading: selectionState.isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  ref.read(selectionStateProvider.notifier).exitSelectionMode();
                },
              )
            : null,
        actions: [
          if (selectionState.isSelectionMode)
            IconButton(
              icon: const Icon(Icons.select_all),
              onPressed: () {
                tasksAsyncValue.whenData((tasks) {
                  final taskIds = tasks.map((t) => t.id).toList();
                  ref.read(selectionStateProvider.notifier).selectAll(taskIds);
                });
              },
            )
          else ...[
            PopupMenuButton<TaskSortOrder>(
              icon: const Icon(Icons.sort),
              tooltip: 'Sort tasks',
              onSelected: (order) {
                ref.read(taskSortOrderProvider.notifier).state = order;
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: TaskSortOrder.byType,
                  child: Row(
                    children: [
                      Icon(
                        Icons.category,
                        color: sortOrder == TaskSortOrder.byType
                            ? Theme.of(context).primaryColor
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'By Type',
                        style: TextStyle(
                          fontWeight: sortOrder == TaskSortOrder.byType
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: TaskSortOrder.byPriority,
                  child: Row(
                    children: [
                      Icon(
                        Icons.priority_high,
                        color: sortOrder == TaskSortOrder.byPriority
                            ? Theme.of(context).primaryColor
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'By Priority',
                        style: TextStyle(
                          fontWeight: sortOrder == TaskSortOrder.byPriority
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: TaskSortOrder.byCreatedDate,
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: sortOrder == TaskSortOrder.byCreatedDate
                            ? Theme.of(context).primaryColor
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'By Date',
                        style: TextStyle(
                          fontWeight: sortOrder == TaskSortOrder.byCreatedDate
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.checklist),
              tooltip: 'Select tasks',
              onPressed: () {
                ref.read(selectionStateProvider.notifier).toggleSelectionMode();
              },
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // TODO: Implement search
              },
            ),
          ],
        ],
      ),
      body: tasksAsyncValue.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return Column(
              children: [
                // Show heatmap even when no tasks
                if (heatmapVisibility.value == true) const CompletionHeatmap(),
                Expanded(
                  child: Center(
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
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              // Show heatmap at the top
              if (heatmapVisibility.value == true) const CompletionHeatmap(),
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return TaskListTile(
                      task: task,
                      isSelectionMode: selectionState.isSelectionMode,
                      isSelected: selectionState.isSelected(task.id),
                      onSelectionChanged: () {
                        ref
                            .read(selectionStateProvider.notifier)
                            .toggleTaskSelection(task.id);
                      },
                    );
                  },
                ),
              ),
              // Bulk action bar
              if (selectionState.isSelectionMode &&
                  selectionState.selectedCount > 0)
                _BulkActionBar(selectedTaskIds: selectionState.selectedTaskIds),
            ],
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
          final result = await Navigator.push<TaskInputResult>(
            context,
            MaterialPageRoute(builder: (context) => const TaskInputPage()),
          );

          if (result != null && context.mounted) {
            await ref.read(taskNotifierProvider.notifier).addTask(result.task);

            // Add reminder if provided
            if (result.reminder != null) {
              final reminderRepo = ref.read(reminderRepositoryProvider);
              await reminderRepo.addReminder(result.reminder!);
            }

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

/// Bulk action bar for multi-select operations
class _BulkActionBar extends ConsumerWidget {
  final Set<String> selectedTaskIds;

  const _BulkActionBar({required this.selectedTaskIds});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _handleBulkComplete(context, ref),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Complete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _handleBulkDelete(context, ref),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleBulkComplete(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Tasks'),
        content: Text('Mark ${selectedTaskIds.length} task(s) as completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Complete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await ref
          .read(taskNotifierProvider.notifier)
          .bulkCompleteTasks(selectedTaskIds.toList());
      ref.read(selectionStateProvider.notifier).exitSelectionMode();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${selectedTaskIds.length} task(s) completed'),
          ),
        );
      }
    }
  }

  Future<void> _handleBulkDelete(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tasks'),
        content: Text(
          'Delete ${selectedTaskIds.length} task(s)? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await ref
          .read(taskNotifierProvider.notifier)
          .bulkDeleteTasks(selectedTaskIds.toList());
      ref.read(selectionStateProvider.notifier).exitSelectionMode();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${selectedTaskIds.length} task(s) deleted')),
        );
      }
    }
  }
}

/// Widget for displaying a single task in the list
class TaskListTile extends ConsumerWidget {
  final TaskEntity task;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onSelectionChanged;

  const TaskListTile({
    super.key,
    required this.task,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUrgent = task.priority == TaskPriority.urgent;

    return Container(
      decoration: isUrgent && !task.isCompleted
          ? BoxDecoration(
              border: Border(left: BorderSide(color: Colors.red, width: 4)),
            )
          : null,
      child: ListTile(
        selected: isSelected,
        tileColor: isUrgent && !task.isCompleted
            ? Colors.red.withValues(alpha: 0.05)
            : null,
        leading: isSelectionMode
            ? Checkbox(
                value: isSelected,
                onChanged: (_) => onSelectionChanged?.call(),
              )
            : Icon(
                _getTaskIcon(task.taskType),
                color: task.isCompleted
                    ? Colors.green
                    : (isUrgent ? Colors.red : null),
              ),
        title: Row(
          children: [
            if (isUrgent && !task.isCompleted) ...[
              const Icon(Icons.priority_high, color: Colors.red, size: 20),
              const SizedBox(width: 4),
            ],
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                  fontWeight: isUrgent && !task.isCompleted
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
        subtitle: _buildSubtitle(),
        trailing: isSelectionMode
            ? null
            : Row(
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
        onTap: isSelectionMode
            ? onSelectionChanged
            : () async {
                final result = await Navigator.push<TaskInputResult>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskInputPage(existingTask: task),
                  ),
                );

                if (result != null && context.mounted) {
                  await ref
                      .read(taskNotifierProvider.notifier)
                      .updateTask(result.task);

                  // Add or update reminder if provided
                  if (result.reminder != null) {
                    final reminderRepo = ref.read(reminderRepositoryProvider);
                    await reminderRepo.addReminder(result.reminder!);
                  }

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
                final result = await Navigator.push<TaskInputResult>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskInputPage(existingTask: task),
                  ),
                );
                if (result != null && context.mounted) {
                  await ref
                      .read(taskNotifierProvider.notifier)
                      .updateTask(result.task);

                  // Add or update reminder if provided
                  if (result.reminder != null) {
                    final reminderRepo = ref.read(reminderRepositoryProvider);
                    await reminderRepo.addReminder(result.reminder!);
                  }

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

/// Blueprints page - Manage recurring task templates
class BlueprintsPage extends ConsumerWidget {
  const BlueprintsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blueprintsAsync = ref.watch(blueprintsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blueprints'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Add filter options
            },
          ),
        ],
      ),
      body: blueprintsAsync.when(
        data: (blueprints) {
          if (blueprints.isEmpty) {
            return const Center(
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
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: blueprints.length,
            itemBuilder: (context, index) {
              final blueprint = blueprints[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: blueprint.isActive
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                    child: Icon(
                      blueprint.isActive ? Icons.repeat : Icons.pause,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(blueprint.name),
                  subtitle: blueprint.description != null
                      ? Text(
                          blueprint.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                      : Text(
                          blueprint.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            color: blueprint.isActive
                                ? Colors.green
                                : Colors.grey,
                          ),
                        ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      if (blueprint.isActive)
                        const PopupMenuItem(
                          value: 'generate',
                          child: Row(
                            children: [
                              Icon(Icons.play_arrow, color: Colors.green),
                              SizedBox(width: 8),
                              Text('Generate Tasks'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) async {
                      if (value == 'generate') {
                        await _generateTasksFromBlueprint(
                          context,
                          ref,
                          blueprint.id,
                        );
                      } else if (value == 'edit') {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BlueprintInputPage(blueprint: blueprint),
                          ),
                        );
                        ref.invalidate(blueprintsProvider);
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(context, ref, blueprint.id);
                      }
                    },
                  ),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            BlueprintInputPage(blueprint: blueprint),
                      ),
                    );
                    ref.invalidate(blueprintsProvider);
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Error loading blueprints: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BlueprintInputPage()),
          );
          ref.invalidate(blueprintsProvider);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _generateTasksFromBlueprint(
    BuildContext context,
    WidgetRef ref,
    String blueprintId,
  ) async {
    try {
      final blueprintRepo = ref.read(blueprintRepositoryProvider);
      final taskRepo = ref.read(taskRepositoryProvider);

      // Get blueprint and its tasks
      final blueprint = await blueprintRepo.getBlueprintById(blueprintId);
      if (blueprint == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Blueprint not found')));
        }
        return;
      }

      final blueprintTasks = await blueprintRepo.getTasksByBlueprintId(
        blueprintId,
      );

      if (blueprintTasks.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Blueprint has no tasks to generate')),
          );
        }
        return;
      }

      // Filter tasks by current weekday
      final currentWeekday = DateTime.now().weekday;
      final filteredTasks = blueprintTasks.where((task) {
        // null weekday means "any day"
        return task.weekday == null || task.weekday == currentWeekday;
      }).toList();

      if (filteredTasks.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No tasks scheduled for today in this blueprint'),
            ),
          );
        }
        return;
      }

      if (!context.mounted) return;

      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Generate Tasks'),
          content: Text(
            'Generate ${filteredTasks.length} task(s) from "${blueprint.name}"?\n\n'
            'Generated tasks can be modified or deleted independently.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Generate'),
            ),
          ],
        ),
      );

      if (confirmed != true || !context.mounted) return;

      final now = DateTime.now();
      int generatedCount = 0;
      int skippedCount = 0;

      // Get all existing tasks to check for duplicates
      final existingTasks = await taskRepo.getAllTasks();

      // Generate tasks from blueprint
      for (final blueprintTask in filteredTasks) {
        final taskType = _parseTaskType(blueprintTask.taskType);

        DateTime? deadline;
        DateTime? timeBasedStart;
        DateTime? timeBasedEnd;

        // Set times based on task type and default time
        if (blueprintTask.defaultTime != null) {
          final timeParts = blueprintTask.defaultTime!.split(':');
          final hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);

          if (taskType == TaskType.deadline) {
            deadline = DateTime(now.year, now.month, now.day, hour, minute);
          } else if (taskType == TaskType.timeBased) {
            timeBasedStart = DateTime(
              now.year,
              now.month,
              now.day,
              hour,
              minute,
            );
            // Default 1 hour duration
            timeBasedEnd = timeBasedStart.add(const Duration(hours: 1));
          }
        }

        // Check for duplicate tasks
        bool isDuplicate = false;
        for (final existingTask in existingTasks) {
          if (existingTask.title.toLowerCase() ==
                  blueprintTask.title.toLowerCase() &&
              existingTask.taskType == taskType) {
            // For unsure tasks, title + type match means duplicate
            if (taskType == TaskType.unsure) {
              isDuplicate = true;
              break;
            }

            // For deadline tasks, also check if deadline matches
            if (taskType == TaskType.deadline &&
                existingTask.deadline != null &&
                deadline != null) {
              if (existingTask.deadline!.year == deadline.year &&
                  existingTask.deadline!.month == deadline.month &&
                  existingTask.deadline!.day == deadline.day &&
                  existingTask.deadline!.hour == deadline.hour &&
                  existingTask.deadline!.minute == deadline.minute) {
                isDuplicate = true;
                break;
              }
            }

            // For time-based tasks, also check if start time matches
            if (taskType == TaskType.timeBased &&
                existingTask.timeBasedStart != null &&
                timeBasedStart != null) {
              if (existingTask.timeBasedStart!.year == timeBasedStart.year &&
                  existingTask.timeBasedStart!.month == timeBasedStart.month &&
                  existingTask.timeBasedStart!.day == timeBasedStart.day &&
                  existingTask.timeBasedStart!.hour == timeBasedStart.hour &&
                  existingTask.timeBasedStart!.minute ==
                      timeBasedStart.minute) {
                isDuplicate = true;
                break;
              }
            }
          }
        }

        // Skip if duplicate found
        if (isDuplicate) {
          skippedCount++;
          continue;
        }

        final task = TaskEntity(
          id: '${DateTime.now().millisecondsSinceEpoch}_$generatedCount',
          title: blueprintTask.title,
          description: blueprintTask.description,
          taskType: taskType,
          deadline: deadline,
          timeBasedStart: timeBasedStart,
          timeBasedEnd: timeBasedEnd,
          createdAt: now,
          updatedAt: now,
        );

        await taskRepo.createTask(task);
        generatedCount++;
      }

      // Refresh task list
      ref.invalidate(taskNotifierProvider);

      if (context.mounted) {
        final message = skippedCount > 0
            ? 'Generated $generatedCount task(s), skipped $skippedCount duplicate(s)'
            : 'Generated $generatedCount task(s) from blueprint';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            action: SnackBarAction(
              label: 'View',
              onPressed: () {
                ref.read(navigationIndexProvider.notifier).state = 0;
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error generating tasks: $e')));
      }
    }
  }

  TaskType _parseTaskType(String taskType) {
    switch (taskType) {
      case 'deadline':
        return TaskType.deadline;
      case 'timeBased':
        return TaskType.timeBased;
      default:
        return TaskType.unsure;
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    String blueprintId,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Blueprint'),
        content: const Text(
          'Are you sure you want to delete this blueprint? '
          'This will not affect any existing tasks created from this blueprint.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                final repository = ref.read(blueprintRepositoryProvider);
                await repository.deleteBlueprint(blueprintId);
                ref.invalidate(blueprintsProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Blueprint deleted successfully'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting blueprint: $e')),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
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
              'Notifications',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          _InactivityReminderTile(),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Alarms',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          _AlarmsTile(),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Display',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          _HeatmapVisibilityTile(),
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
            leading: const Icon(Icons.history),
            title: const Text('Task Logs'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const TaskLogsPage()),
              );
            },
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

/// Inactivity reminder configuration tile
class _InactivityReminderTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabledAsync = ref.watch(inactivityReminderEnabledProvider);
    final timeAsync = ref.watch(inactivityReminderTimeProvider);

    return enabledAsync.when(
      data: (enabled) => ListTile(
        leading: const Icon(Icons.notifications_paused_outlined),
        title: const Text('Inactivity Reminder'),
        subtitle: timeAsync.when(
          data: (time) => Text(enabled ? 'Daily at $time' : 'Disabled'),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Error loading time'),
        ),
        trailing: Switch(
          value: enabled,
          onChanged: (value) async {
            final service = ref.read(inactivityReminderServiceProvider);
            await service.setEnabled(value);
            ref.invalidate(inactivityReminderEnabledProvider);
          },
        ),
        onTap: enabled
            ? () => _showTimePickerDialog(
                context,
                ref,
                timeAsync.value ?? '09:00',
              )
            : null,
      ),
      loading: () => const ListTile(
        leading: Icon(Icons.notifications_paused_outlined),
        title: Text('Inactivity Reminder'),
        subtitle: Text('Loading...'),
      ),
      error: (_, __) => const ListTile(
        leading: Icon(Icons.notifications_paused_outlined),
        title: Text('Inactivity Reminder'),
        subtitle: Text('Error loading settings'),
      ),
    );
  }

  Future<void> _showTimePickerDialog(
    BuildContext context,
    WidgetRef ref,
    String currentTime,
  ) async {
    final timeParts = currentTime.split(':');
    final currentTimeOfDay = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: currentTimeOfDay,
    );

    if (picked != null && context.mounted) {
      final timeString =
          '${picked.hour.toString().padLeft(2, '0')}:'
          '${picked.minute.toString().padLeft(2, '0')}';

      final service = ref.read(inactivityReminderServiceProvider);
      await service.setReminderTime(timeString);
      ref.invalidate(inactivityReminderTimeProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Inactivity reminder set for $timeString')),
        );
      }
    }
  }
}

/// Alarms tile for setting native Android alarms
class _AlarmsTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.alarm),
      title: const Text('Set Alarm'),
      subtitle: const Text('Open Android system alarm clock'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showAlarmDialog(context, ref),
    );
  }

  Future<void> _showAlarmDialog(BuildContext context, WidgetRef ref) async {
    final alarmService = ref.read(alarmServiceProvider);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Set Alarm'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose how to set your alarm:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.alarm_add),
              title: const Text('Set New Alarm'),
              subtitle: const Text('Create alarm with specific time'),
              onTap: () {
                Navigator.of(dialogContext).pop();
                _showTimePickerForAlarm(context, ref, alarmService);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.alarm_outlined),
              title: const Text('Open Alarms'),
              subtitle: const Text('View all system alarms'),
              onTap: () async {
                Navigator.of(dialogContext).pop();
                final success = await alarmService.openAlarms();
                if (context.mounted) {
                  if (!success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to open alarms app'),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _showTimePickerForAlarm(
    BuildContext context,
    WidgetRef ref,
    dynamic alarmService,
  ) async {
    final now = TimeOfDay.now();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: now,
    );

    if (picked != null && context.mounted) {
      // Show optional message dialog
      final messageController = TextEditingController();
      final bool? setMessage = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) => AlertDialog(
          title: const Text('Alarm Label'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Add an optional label for your alarm:'),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'Alarm label (optional)',
                  hintText: 'Wake up',
                  border: OutlineInputBorder(),
                ),
                maxLength: 50,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Skip'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Set Alarm'),
            ),
          ],
        ),
      );

      if (setMessage != null && context.mounted) {
        final message = messageController.text.trim().isEmpty
            ? null
            : messageController.text.trim();

        final success = await alarmService.setAlarm(
          hour: picked.hour,
          minute: picked.minute,
          message: message,
        );

        if (context.mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Opening system alarm clock at ${picked.format(context)}',
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to set alarm')),
            );
          }
        }
      }
    }
  }
}

/// Tile for toggling completion heatmap visibility
class _HeatmapVisibilityTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heatmapVisibility = ref.watch(heatmapVisibilityProvider);

    return heatmapVisibility.when(
      data: (isVisible) => SwitchListTile(
        secondary: const Icon(Icons.grid_on),
        title: const Text('Completion Heatmap'),
        subtitle: Text(isVisible ? 'Visible on Tasks page' : 'Hidden'),
        value: isVisible,
        onChanged: (value) {
          ref.read(heatmapVisibilityProvider.notifier).setVisibility(value);
        },
      ),
      loading: () => const ListTile(
        leading: Icon(Icons.grid_on),
        title: Text('Completion Heatmap'),
        trailing: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (_, __) => const ListTile(
        leading: Icon(Icons.grid_on),
        title: Text('Completion Heatmap'),
        subtitle: Text('Error loading setting'),
      ),
    );
  }
}
