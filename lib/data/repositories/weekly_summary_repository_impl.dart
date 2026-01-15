import '../../domain/entities/weekly_summary_entity.dart';
import '../../domain/repositories/weekly_summary_repository.dart';
import '../datasources/local/weekly_summary_local_data_source.dart';
import '../models/weekly_summary_model.dart';

/// Implementation of WeeklySummaryRepository
class WeeklySummaryRepositoryImpl implements WeeklySummaryRepository {
  final WeeklySummaryLocalDataSource _localDataSource;

  WeeklySummaryRepositoryImpl({WeeklySummaryLocalDataSource? localDataSource})
    : _localDataSource = localDataSource ?? WeeklySummaryLocalDataSource();

  @override
  Future<void> createSummary(WeeklySummaryEntity summary) async {
    final model = WeeklySummaryModel.fromEntity(summary);
    await _localDataSource.createSummary(model);
  }

  @override
  Future<WeeklySummaryEntity?> getSummaryById(String id) async {
    final model = await _localDataSource.getSummaryById(id);
    return model?.toEntity();
  }

  @override
  Future<WeeklySummaryEntity?> getSummaryByWeekStart(DateTime weekStart) async {
    final model = await _localDataSource.getSummaryByWeekStart(weekStart);
    return model?.toEntity();
  }

  @override
  Future<List<WeeklySummaryEntity>> getAllSummaries() async {
    final models = await _localDataSource.getAllSummaries();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<WeeklySummaryEntity>> getSummariesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final models = await _localDataSource.getSummariesByDateRange(
      startDate,
      endDate,
    );
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> deleteSummary(String id) async {
    await _localDataSource.deleteSummary(id);
  }

  @override
  Future<void> deleteAllSummaries() async {
    await _localDataSource.deleteAllSummaries();
  }
}
