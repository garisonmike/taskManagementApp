/// Weekly summary entity - immutable domain model for weekly task statistics
class WeeklySummaryEntity {
  final String id;
  final DateTime weekStartDate; // Monday of the week
  final DateTime weekEndDate; // Sunday of the week
  final int totalTasks;
  final int completedTasks;
  final int failedTasks;
  final int postponedTasks;
  final int droppedTasks;
  final int deletedTasks;
  final double completionRate; // Percentage of completed tasks
  final DateTime createdAt;

  const WeeklySummaryEntity({
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeeklySummaryEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          weekStartDate == other.weekStartDate &&
          weekEndDate == other.weekEndDate &&
          totalTasks == other.totalTasks &&
          completedTasks == other.completedTasks &&
          failedTasks == other.failedTasks &&
          postponedTasks == other.postponedTasks &&
          droppedTasks == other.droppedTasks &&
          deletedTasks == other.deletedTasks &&
          completionRate == other.completionRate &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      weekStartDate.hashCode ^
      weekEndDate.hashCode ^
      totalTasks.hashCode ^
      completedTasks.hashCode ^
      failedTasks.hashCode ^
      postponedTasks.hashCode ^
      droppedTasks.hashCode ^
      deletedTasks.hashCode ^
      completionRate.hashCode ^
      createdAt.hashCode;
}
