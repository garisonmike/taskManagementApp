import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/reminder_entity.dart';
import '../../domain/entities/task_entity.dart';

/// Result data from TaskInputPage
class TaskInputResult {
  final TaskEntity task;
  final ReminderEntity? reminder;

  TaskInputResult({required this.task, this.reminder});
}

/// Page for adding or editing a task
class TaskInputPage extends ConsumerStatefulWidget {
  final TaskEntity? existingTask; // null for add, non-null for edit

  const TaskInputPage({super.key, this.existingTask});

  @override
  ConsumerState<TaskInputPage> createState() => _TaskInputPageState();
}

class _TaskInputPageState extends ConsumerState<TaskInputPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late TaskType _selectedTaskType;
  DateTime? _selectedDeadline;
  DateTime? _timeBasedStart;
  DateTime? _timeBasedEnd;

  // Reminder state
  bool _enableReminder = false;
  DateTime? _reminderTime;
  ReminderPriority _reminderPriority = ReminderPriority.normal;

  @override
  void initState() {
    super.initState();

    // Initialize with existing task data if editing
    final task = widget.existingTask;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(
      text: task?.description ?? '',
    );
    _selectedTaskType = task?.taskType ?? TaskType.unsure;
    _selectedDeadline = task?.deadline;
    _timeBasedStart = task?.timeBasedStart;
    _timeBasedEnd = task?.timeBasedEnd;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.existingTask != null;

  String? _validateDeadlineRequired() {
    if (_selectedTaskType == TaskType.deadline && _selectedDeadline == null) {
      return 'Deadline is required for deadline-based tasks';
    }
    return null;
  }

  void _saveTask() {
    // Validate deadline requirement
    final deadlineError = _validateDeadlineRequired();
    if (deadlineError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(deadlineError), backgroundColor: Colors.red),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();

      // Create or update task
      final task = TaskEntity(
        id:
            widget.existingTask?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        taskType: _selectedTaskType,
        deadline: _selectedTaskType == TaskType.deadline
            ? _selectedDeadline
            : null,
        timeBasedStart: _selectedTaskType == TaskType.timeBased
            ? _timeBasedStart
            : null,
        timeBasedEnd: _selectedTaskType == TaskType.timeBased
            ? _timeBasedEnd
            : null,
        isCompleted: widget.existingTask?.isCompleted ?? false,
        completionDate: widget.existingTask?.completionDate,
        failureReason: widget.existingTask?.failureReason,
        isPostponed: widget.existingTask?.isPostponed ?? false,
        isDropped: widget.existingTask?.isDropped ?? false,
        createdAt: widget.existingTask?.createdAt ?? now,
        updatedAt: now,
      );

      // Create reminder if enabled
      ReminderEntity? reminder;
      if (_enableReminder && _reminderTime != null) {
        reminder = ReminderEntity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          taskId: task.id,
          reminderTime: _reminderTime!,
          isEnabled: true,
          priority: _reminderPriority,
          createdAt: now,
        );
      }

      Navigator.of(
        context,
      ).pop(TaskInputResult(task: task, reminder: reminder));
    }
  }

  Future<void> _selectDeadline() async {
    if (!mounted) return;

    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          _selectedDeadline ?? DateTime.now(),
        ),
      );

      if (time != null && mounted) {
        setState(() {
          _selectedDeadline = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _selectTimeBasedStart() async {
    if (!mounted) return;

    final date = await showDatePicker(
      context: context,
      initialDate: _timeBasedStart ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_timeBasedStart ?? DateTime.now()),
      );

      if (time != null && mounted) {
        setState(() {
          _timeBasedStart = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _selectTimeBasedEnd() async {
    if (!mounted) return;

    final initialDate = _timeBasedEnd ?? _timeBasedStart ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: _timeBasedStart ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      if (time != null && mounted) {
        setState(() {
          _timeBasedEnd = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _selectReminderTime() async {
    if (!mounted) return;

    final date = await showDatePicker(
      context: context,
      initialDate: _reminderTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_reminderTime ?? DateTime.now()),
      );

      if (time != null && mounted) {
        setState(() {
          _reminderTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Task' : 'Add Task'),
        actions: [TextButton(onPressed: _saveTask, child: const Text('Save'))],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title field (required)
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'Enter task title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Description field (optional)
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter task description (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 24),

            // Task type selector
            const Text(
              'Task Type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SegmentedButton<TaskType>(
              segments: const [
                ButtonSegment(
                  value: TaskType.unsure,
                  label: Text('Unsure'),
                  icon: Icon(Icons.help_outline),
                ),
                ButtonSegment(
                  value: TaskType.deadline,
                  label: Text('Deadline'),
                  icon: Icon(Icons.event),
                ),
                ButtonSegment(
                  value: TaskType.timeBased,
                  label: Text('Time-based'),
                  icon: Icon(Icons.schedule),
                ),
              ],
              selected: {_selectedTaskType},
              onSelectionChanged: (Set<TaskType> selected) {
                setState(() {
                  _selectedTaskType = selected.first;
                });
              },
            ),
            const SizedBox(height: 24),

            // Deadline picker (for deadline tasks)
            if (_selectedTaskType == TaskType.deadline) ...[
              ListTile(
                leading: const Icon(Icons.event),
                title: const Text('Deadline'),
                subtitle: Text(
                  _selectedDeadline != null
                      ? _formatDateTime(_selectedDeadline!)
                      : 'Not set',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _selectDeadline,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Time-based pickers
            if (_selectedTaskType == TaskType.timeBased) ...[
              ListTile(
                leading: const Icon(Icons.play_arrow),
                title: const Text('Start Time'),
                subtitle: Text(
                  _timeBasedStart != null
                      ? _formatDateTime(_timeBasedStart!)
                      : 'Not set',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _selectTimeBasedStart,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.stop),
                title: const Text('End Time'),
                subtitle: Text(
                  _timeBasedEnd != null
                      ? _formatDateTime(_timeBasedEnd!)
                      : 'Not set',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _selectTimeBasedEnd,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Set Reminder section
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Set Reminder',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: _enableReminder,
                  onChanged: (value) {
                    setState(() {
                      _enableReminder = value;
                      if (!value) {
                        _reminderTime = null;
                        _reminderPriority = ReminderPriority.normal;
                      }
                    });
                  },
                ),
              ],
            ),

            if (_enableReminder) ...[
              const SizedBox(height: 16),

              // Reminder time picker
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Reminder Time'),
                subtitle: Text(
                  _reminderTime != null
                      ? _formatDateTime(_reminderTime!)
                      : 'Not set',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _selectReminderTime,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              const SizedBox(height: 16),

              // Priority selector
              const Text(
                'Priority',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              SegmentedButton<ReminderPriority>(
                segments: const [
                  ButtonSegment(
                    value: ReminderPriority.normal,
                    label: Text('Normal'),
                    icon: Icon(Icons.notifications_outlined),
                  ),
                  ButtonSegment(
                    value: ReminderPriority.urgent,
                    label: Text('Urgent'),
                    icon: Icon(Icons.notification_important),
                  ),
                ],
                selected: {_reminderPriority},
                onSelectionChanged: (Set<ReminderPriority> selected) {
                  setState(() {
                    _reminderPriority = selected.first;
                  });
                },
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
