import 'dart:convert';

import '../../domain/entities/task_log_entity.dart';

/// Data model for TaskLog with database mapping
class TaskLogModel {
  final String id;
  final String taskId;
  final String action;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const TaskLogModel({
    required this.id,
    required this.taskId,
    required this.action,
    required this.timestamp,
    this.metadata,
  });

  /// Convert from domain entity
  factory TaskLogModel.fromEntity(TaskLogEntity entity) {
    return TaskLogModel(
      id: entity.id,
      taskId: entity.taskId,
      action: _actionToString(entity.action),
      timestamp: entity.timestamp,
      metadata: entity.metadata,
    );
  }

  /// Convert to domain entity
  TaskLogEntity toEntity() {
    return TaskLogEntity(
      id: id,
      taskId: taskId,
      action: _stringToAction(action),
      timestamp: timestamp,
      metadata: metadata,
    );
  }

  /// Create from database map
  factory TaskLogModel.fromMap(Map<String, dynamic> map) {
    return TaskLogModel(
      id: map['id'] as String,
      taskId: map['task_id'] as String,
      action: map['action'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      metadata: map['metadata'] != null
          ? jsonDecode(map['metadata'] as String) as Map<String, dynamic>
          : null,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'action': action,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'metadata': metadata != null ? jsonEncode(metadata) : null,
    };
  }

  static String _actionToString(TaskLogAction action) {
    return action.name;
  }

  static TaskLogAction _stringToAction(String action) {
    return TaskLogAction.values.firstWhere(
      (e) => e.name == action,
      orElse: () => TaskLogAction.edited,
    );
  }
}
