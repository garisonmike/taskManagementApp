import '../../domain/entities/blueprint_task_entity.dart';

/// Data model for BlueprintTask with database mapping
class BlueprintTaskModel {
  final String id;
  final String blueprintId;
  final String title;
  final String? description;
  final String taskType;
  final String? defaultTime;
  final int? weekday;
  final DateTime createdAt;

  const BlueprintTaskModel({
    required this.id,
    required this.blueprintId,
    required this.title,
    this.description,
    required this.taskType,
    this.defaultTime,
    this.weekday,
    required this.createdAt,
  });

  /// Convert from domain entity
  factory BlueprintTaskModel.fromEntity(BlueprintTaskEntity entity) {
    return BlueprintTaskModel(
      id: entity.id,
      blueprintId: entity.blueprintId,
      title: entity.title,
      description: entity.description,
      taskType: entity.taskType,
      defaultTime: entity.defaultTime,
      weekday: entity.weekday,
      createdAt: entity.createdAt,
    );
  }

  /// Convert to domain entity
  BlueprintTaskEntity toEntity() {
    return BlueprintTaskEntity(
      id: id,
      blueprintId: blueprintId,
      title: title,
      description: description,
      taskType: taskType,
      defaultTime: defaultTime,
      weekday: weekday,
      createdAt: createdAt,
    );
  }

  /// Create from database map
  factory BlueprintTaskModel.fromMap(Map<String, dynamic> map) {
    return BlueprintTaskModel(
      id: map['id'] as String,
      blueprintId: map['blueprint_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      taskType: map['task_type'] as String,
      defaultTime: map['default_time'] as String?,
      weekday: map['weekday'] as int?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'blueprint_id': blueprintId,
      'title': title,
      'description': description,
      'task_type': taskType,
      'default_time': defaultTime,
      'weekday': weekday,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }
}
