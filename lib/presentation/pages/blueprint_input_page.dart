import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/blueprint_entity.dart';
import '../../domain/entities/blueprint_task_entity.dart';
import '../providers/blueprint_provider.dart';

/// Page for creating or editing a blueprint
class BlueprintInputPage extends ConsumerStatefulWidget {
  final BlueprintEntity? blueprint;

  const BlueprintInputPage({super.key, this.blueprint});

  @override
  ConsumerState<BlueprintInputPage> createState() => _BlueprintInputPageState();
}

class _BlueprintInputPageState extends ConsumerState<BlueprintInputPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late bool _isActive;
  List<BlueprintTaskEntity> _tasks = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.blueprint?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.blueprint?.description ?? '',
    );
    _isActive = widget.blueprint?.isActive ?? true;
    _loadBlueprintTasks();
  }

  Future<void> _loadBlueprintTasks() async {
    if (widget.blueprint != null) {
      final repository = ref.read(blueprintRepositoryProvider);
      final tasks = await repository.getTasksByBlueprintId(
        widget.blueprint!.id,
      );
      setState(() {
        _tasks = tasks;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveBlueprint() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(blueprintRepositoryProvider);
      final now = DateTime.now();

      final blueprint =
          widget.blueprint?.copyWith(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            isActive: _isActive,
            updatedAt: now,
          ) ??
          BlueprintEntity(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            isActive: _isActive,
            createdAt: now,
            updatedAt: now,
          );

      if (widget.blueprint == null) {
        await repository.createBlueprint(blueprint);
      } else {
        await repository.updateBlueprint(blueprint);
      }

      // Save all tasks
      for (final task in _tasks) {
        if (widget.blueprint == null) {
          // New blueprint - create task with new blueprint ID
          final newTask = task.copyWith(blueprintId: blueprint.id);
          await repository.createBlueprintTask(newTask);
        } else {
          // Existing blueprint - update or create task
          final existing = await repository.getBlueprintTaskById(task.id);
          if (existing != null) {
            await repository.updateBlueprintTask(task);
          } else {
            await repository.createBlueprintTask(task);
          }
        }
      }

      // Refresh blueprints list
      ref.invalidate(blueprintsProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.blueprint == null
                  ? 'Blueprint created successfully'
                  : 'Blueprint updated successfully',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving blueprint: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _addTask() {
    showDialog(
      context: context,
      builder: (context) => _TaskDialog(
        onSave: (task) {
          setState(() {
            _tasks.add(task);
          });
        },
      ),
    );
  }

  void _editTask(int index) {
    showDialog(
      context: context,
      builder: (context) => _TaskDialog(
        task: _tasks[index],
        onSave: (task) {
          setState(() {
            _tasks[index] = task;
          });
        },
      ),
    );
  }

  void _deleteTask(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Delete "${_tasks[index].title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final task = _tasks[index];
              setState(() {
                _tasks.removeAt(index);
              });

              // If editing existing blueprint, delete from database
              if (widget.blueprint != null) {
                final repository = ref.read(blueprintRepositoryProvider);
                await repository.deleteBlueprintTask(task.id);
              }

              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.blueprint == null ? 'New Blueprint' : 'Edit Blueprint',
        ),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(icon: const Icon(Icons.save), onPressed: _saveBlueprint),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Blueprint Name',
                hintText: 'Morning Routine',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'My daily morning tasks',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Active'),
              subtitle: const Text('Enable this blueprint for task generation'),
              value: _isActive,
              onChanged: (value) {
                setState(() => _isActive = value);
              },
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tasks',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _addTask,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Task'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_tasks.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(
                    child: Text(
                      'No tasks yet. Add tasks to this blueprint.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              )
            else
              ...List.generate(_tasks.length, (index) {
                final task = _tasks[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(_getTaskTypeIcon(task.taskType)),
                    title: Text(task.title),
                    subtitle: task.description != null
                        ? Text(task.description!)
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (task.defaultTime != null)
                          Chip(
                            label: Text(task.defaultTime!),
                            visualDensity: VisualDensity.compact,
                          ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editTask(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteTask(index),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  IconData _getTaskTypeIcon(String taskType) {
    switch (taskType) {
      case 'deadline':
        return Icons.event;
      case 'timeBased':
        return Icons.access_time;
      default:
        return Icons.help_outline;
    }
  }
}

/// Dialog for adding/editing a blueprint task
class _TaskDialog extends StatefulWidget {
  final BlueprintTaskEntity? task;
  final Function(BlueprintTaskEntity) onSave;

  const _TaskDialog({this.task, required this.onSave});

  @override
  State<_TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<_TaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _taskType;
  TimeOfDay? _defaultTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.task?.description ?? '',
    );
    _taskType = widget.task?.taskType ?? 'unsure';
    if (widget.task?.defaultTime != null) {
      final parts = widget.task!.defaultTime!.split(':');
      _defaultTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _defaultTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _defaultTime = picked);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final task =
        widget.task?.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          taskType: _taskType,
          defaultTime: _defaultTime != null
              ? '${_defaultTime!.hour.toString().padLeft(2, '0')}:'
                    '${_defaultTime!.minute.toString().padLeft(2, '0')}'
              : null,
        ) ??
        BlueprintTaskEntity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          blueprintId: '', // Will be set by parent
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          taskType: _taskType,
          defaultTime: _defaultTime != null
              ? '${_defaultTime!.hour.toString().padLeft(2, '0')}:'
                    '${_defaultTime!.minute.toString().padLeft(2, '0')}'
              : null,
          createdAt: DateTime.now(),
        );

    widget.onSave(task);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _taskType,
                decoration: const InputDecoration(
                  labelText: 'Task Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'unsure', child: Text('Unsure')),
                  DropdownMenuItem(value: 'deadline', child: Text('Deadline')),
                  DropdownMenuItem(
                    value: 'timeBased',
                    child: Text('Time-based'),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _taskType = value!);
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Default Time'),
                subtitle: Text(
                  _defaultTime != null
                      ? _defaultTime!.format(context)
                      : 'Not set',
                ),
                trailing: _defaultTime != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _defaultTime = null),
                      )
                    : null,
                onTap: _pickTime,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
