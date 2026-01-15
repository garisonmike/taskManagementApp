import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/weekly_summary_service.dart';
import '../../data/datasources/local/weekly_summary_local_data_source.dart';
import '../../data/repositories/weekly_summary_repository_impl.dart';
import '../../domain/entities/weekly_summary_entity.dart';
import '../../domain/repositories/weekly_summary_repository.dart';
import 'task_log_provider.dart';

/// Provider for WeeklySummaryLocalDataSource
final weeklySummaryLocalDataSourceProvider =
    Provider<WeeklySummaryLocalDataSource>((ref) {
      return WeeklySummaryLocalDataSource();
    });

/// Provider for WeeklySummaryRepository
final weeklySummaryRepositoryProvider = Provider<WeeklySummaryRepository>((
  ref,
) {
  final dataSource = ref.watch(weeklySummaryLocalDataSourceProvider);
  return WeeklySummaryRepositoryImpl(localDataSource: dataSource);
});

/// Provider for WeeklySummaryService
final weeklySummaryServiceProvider = Provider<WeeklySummaryService>((ref) {
  final taskLogRepository = ref.watch(taskLogRepositoryProvider);
  final weeklySummaryRepository = ref.watch(weeklySummaryRepositoryProvider);
  return WeeklySummaryService(
    taskLogRepository: taskLogRepository,
    weeklySummaryRepository: weeklySummaryRepository,
  );
});

/// Provider for all weekly summaries
final weeklySummariesProvider = FutureProvider<List<WeeklySummaryEntity>>((
  ref,
) async {
  final repository = ref.watch(weeklySummaryRepositoryProvider);
  return await repository.getAllSummaries();
});
