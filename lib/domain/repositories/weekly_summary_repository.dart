import '../entities/weekly_summary_entity.dart';

/// Repository interface for weekly summaries
abstract class WeeklySummaryRepository {
  /// Create a new weekly summary
  Future<void> createSummary(WeeklySummaryEntity summary);

  /// Get a specific weekly summary by ID
  Future<WeeklySummaryEntity?> getSummaryById(String id);

  /// Get weekly summary for a specific week start date
  Future<WeeklySummaryEntity?> getSummaryByWeekStart(DateTime weekStart);

  /// Get all weekly summaries ordered by week start date (descending)
  Future<List<WeeklySummaryEntity>> getAllSummaries();

  /// Get summaries within a date range
  Future<List<WeeklySummaryEntity>> getSummariesByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Delete a weekly summary by ID
  Future<void> deleteSummary(String id);

  /// Delete all weekly summaries
  Future<void> deleteAllSummaries();
}
