import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/database_helper.dart';
import '../../data/datasources/local/task_log_local_data_source.dart';
import '../../data/repositories/task_log_repository_impl.dart';
import '../../domain/repositories/task_log_repository.dart';

/// Provider for TaskLogLocalDataSource
final taskLogLocalDataSourceProvider = Provider<TaskLogLocalDataSource>((ref) {
  return TaskLogLocalDataSource(DatabaseHelper.instance);
});

/// Provider for TaskLogRepository
final taskLogRepositoryProvider = Provider<TaskLogRepository>((ref) {
  return TaskLogRepositoryImpl(ref.watch(taskLogLocalDataSourceProvider));
});
