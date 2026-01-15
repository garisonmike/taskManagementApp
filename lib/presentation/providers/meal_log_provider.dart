import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/database_helper.dart';
import '../../data/datasources/local/meal_log_local_data_source.dart';
import '../../data/repositories/meal_log_repository.dart';
import '../../domain/entities/meal_log_entity.dart';

/// Provider for meal log local data source
final mealLogLocalDataSourceProvider = Provider<MealLogLocalDataSource>((ref) {
  final dbHelper = DatabaseHelper.instance;
  return MealLogLocalDataSource(dbHelper);
});

/// Provider for meal log repository
final mealLogRepositoryProvider = Provider<MealLogRepository>((ref) {
  final dataSource = ref.watch(mealLogLocalDataSourceProvider);
  return MealLogRepository(dataSource);
});

/// Provider for all meal logs
final mealLogsProvider = FutureProvider<List<MealLogEntity>>((ref) async {
  final repository = ref.watch(mealLogRepositoryProvider);
  return await repository.getAllLogs();
});

/// Provider for meal logs by date range
final mealLogsByDateRangeProvider =
    FutureProvider.family<
      List<MealLogEntity>,
      ({DateTime startDate, DateTime endDate})
    >((ref, params) async {
      final repository = ref.watch(mealLogRepositoryProvider);
      return await repository.getLogsByDateRange(
        startDate: params.startDate,
        endDate: params.endDate,
      );
    });
