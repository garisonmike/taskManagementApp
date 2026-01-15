import '../../domain/entities/task_log_entity.dart';
import '../../domain/entities/weekly_summary_entity.dart';
import '../../domain/repositories/task_log_repository.dart';
import '../../domain/repositories/weekly_summary_repository.dart';

/// Service for generating weekly summaries from task logs
class WeeklySummaryService {
  final TaskLogRepository _taskLogRepository;
  final WeeklySummaryRepository _weeklySummaryRepository;

  WeeklySummaryService({
    required TaskLogRepository taskLogRepository,
    required WeeklySummaryRepository weeklySummaryRepository,
  }) : _taskLogRepository = taskLogRepository,
       _weeklySummaryRepository = weeklySummaryRepository;

  /// Generate a weekly summary for a specific week
  /// [weekStartDate] should be a Monday
  Future<WeeklySummaryEntity> generateWeeklySummary(
    DateTime weekStartDate,
  ) async {
    // Ensure weekStartDate is Monday
    final monday = _getMondayOfWeek(weekStartDate);
    final sunday = monday.add(const Duration(days: 6));

    // Get all logs for the week
    final logs = await _taskLogRepository.getLogsByDateRange(
      monday,
      sunday.add(const Duration(hours: 23, minutes: 59, seconds: 59)),
    );

    // Count tasks by action
    final taskIds = <String>{};
    int completedCount = 0;
    int failedCount = 0;
    int postponedCount = 0;
    int droppedCount = 0;
    int deletedCount = 0;

    for (final log in logs) {
      taskIds.add(log.taskId);

      switch (log.action) {
        case TaskLogAction.completed:
          completedCount++;
          break;
        case TaskLogAction.failed:
          failedCount++;
          break;
        case TaskLogAction.postponed:
          postponedCount++;
          break;
        case TaskLogAction.dropped:
          droppedCount++;
          break;
        case TaskLogAction.deleted:
          deletedCount++;
          break;
        case TaskLogAction.created:
        case TaskLogAction.edited:
          // Don't count these for statistics
          break;
      }
    }

    final totalTasks = taskIds.length;
    final completionRate = totalTasks > 0
        ? (completedCount / totalTasks * 100).roundToDouble()
        : 0.0;

    final summary = WeeklySummaryEntity(
      id: monday.millisecondsSinceEpoch.toString(),
      weekStartDate: monday,
      weekEndDate: sunday,
      totalTasks: totalTasks,
      completedTasks: completedCount,
      failedTasks: failedCount,
      postponedTasks: postponedCount,
      droppedTasks: droppedCount,
      deletedTasks: deletedCount,
      completionRate: completionRate,
      createdAt: DateTime.now(),
    );

    // Save the summary
    await _weeklySummaryRepository.createSummary(summary);

    return summary;
  }

  /// Generate summary for the current week
  Future<WeeklySummaryEntity> generateCurrentWeekSummary() async {
    final now = DateTime.now();
    return await generateWeeklySummary(now);
  }

  /// Generate summary for the previous week (useful for Saturday night generation)
  Future<WeeklySummaryEntity> generatePreviousWeekSummary() async {
    final now = DateTime.now();
    final lastWeek = now.subtract(const Duration(days: 7));
    return await generateWeeklySummary(lastWeek);
  }

  /// Check if a summary already exists for a given week
  Future<bool> summaryExistsForWeek(DateTime date) async {
    final monday = _getMondayOfWeek(date);
    final existing = await _weeklySummaryRepository.getSummaryByWeekStart(
      monday,
    );
    return existing != null;
  }

  /// Get Monday of the week for a given date
  DateTime _getMondayOfWeek(DateTime date) {
    // DateTime.weekday returns 1 for Monday, 7 for Sunday
    final daysFromMonday = date.weekday - 1;
    return DateTime(date.year, date.month, date.day - daysFromMonday);
  }

  /// Auto-generate weekly summary (called on Saturday nights)
  /// Only generates if summary doesn't already exist for the week
  Future<WeeklySummaryEntity?> autoGenerateWeeklySummary() async {
    final now = DateTime.now();

    // Check if today is Saturday (weekday == 6)
    if (now.weekday != DateTime.saturday) {
      return null; // Not Saturday, don't generate
    }

    // Generate for the current week (Monday to Sunday)
    final exists = await summaryExistsForWeek(now);
    if (exists) {
      return null; // Summary already exists
    }

    return await generateCurrentWeekSummary();
  }
}
