import '../../domain/entities/weekly_summary_entity.dart';

/// Data model for weekly summary with database mapping
class WeeklySummaryModel {
  final String id;
  final String weekStartDate; // ISO 8601 date string
  final String weekEndDate; // ISO 8601 date string
  final int totalTasks;
  final int completedTasks;
  final int failedTasks;
  final int postponedTasks;
  final int droppedTasks;
  final int deletedTasks;
  final double completionRate;
  final String createdAt; // ISO 8601 datetime string

  const WeeklySummaryModel({
    required this.id,
    required this.weekStartDate,
    required this.weekEndDate,
    required this.totalTasks,
    required this.completedTasks,
    required this.failedTasks,
    required this.postponedTasks,
    required this.droppedTasks,
    required this.deletedTasks,
    required this.completionRate,
    required this.createdAt,
  });

  /// Convert from database map
  factory WeeklySummaryModel.fromMap(Map<String, dynamic> map) {
    return WeeklySummaryModel(
      id: map['id'] as String,
      weekStartDate: map['week_start_date'] as String,
      weekEndDate: map['week_end_date'] as String,
      totalTasks: map['total_tasks'] as int,
      completedTasks: map['completed_tasks'] as int,
      failedTasks: map['failed_tasks'] as int,
      postponedTasks: map['postponed_tasks'] as int,
      droppedTasks: map['dropped_tasks'] as int,
      deletedTasks: map['deleted_tasks'] as int,
      completionRate: map['completion_rate'] as double,
      createdAt: map['created_at'] as String,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'week_start_date': weekStartDate,
      'week_end_date': weekEndDate,
      'total_tasks': totalTasks,
      'completed_tasks': completedTasks,
      'failed_tasks': failedTasks,
      'postponed_tasks': postponedTasks,
      'dropped_tasks': droppedTasks,
      'deleted_tasks': deletedTasks,
      'completion_rate': completionRate,
      'created_at': createdAt,
    };
  }

  /// Convert to domain entity
  WeeklySummaryEntity toEntity() {
    return WeeklySummaryEntity(
      id: id,
      weekStartDate: DateTime.parse(weekStartDate),
      weekEndDate: DateTime.parse(weekEndDate),
      totalTasks: totalTasks,
      completedTasks: completedTasks,
      failedTasks: failedTasks,
      postponedTasks: postponedTasks,
      droppedTasks: droppedTasks,
      deletedTasks: deletedTasks,
      completionRate: completionRate,
      createdAt: DateTime.parse(createdAt),
    );
  }

  /// Create from domain entity
  factory WeeklySummaryModel.fromEntity(WeeklySummaryEntity entity) {
    return WeeklySummaryModel(
      id: entity.id,
      weekStartDate: entity.weekStartDate.toIso8601String(),
      weekEndDate: entity.weekEndDate.toIso8601String(),
      totalTasks: entity.totalTasks,
      completedTasks: entity.completedTasks,
      failedTasks: entity.failedTasks,
      postponedTasks: entity.postponedTasks,
      droppedTasks: entity.droppedTasks,
      deletedTasks: entity.deletedTasks,
      completionRate: entity.completionRate,
      createdAt: entity.createdAt.toIso8601String(),
    );
  }
}
