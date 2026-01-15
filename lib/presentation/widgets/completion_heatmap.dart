import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/task_log_entity.dart';
import '../providers/task_log_provider.dart';

/// GitHub-style heatmap widget showing daily task completion
class CompletionHeatmap extends ConsumerStatefulWidget {
  const CompletionHeatmap({super.key});

  @override
  ConsumerState<CompletionHeatmap> createState() => _CompletionHeatmapState();
}

class _CompletionHeatmapState extends ConsumerState<CompletionHeatmap> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<DateTime, int>>(
      future: _getCompletionData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        final completionData = snapshot.data ?? {};

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Daily Completion Activity',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildHeatmap(completionData),
            ),
            Padding(padding: const EdgeInsets.all(16.0), child: _buildLegend()),
          ],
        );
      },
    );
  }

  /// Build the heatmap grid
  Widget _buildHeatmap(Map<DateTime, int> data) {
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 364)); // ~1 year

    // Group dates by week
    final weeks = <List<DateTime>>[];
    var currentWeek = <DateTime>[];
    var currentDate = _normalizeDate(startDate);

    // Start from the Monday of the first week
    while (currentDate.weekday != DateTime.monday) {
      currentDate = currentDate.subtract(const Duration(days: 1));
    }

    while (currentDate.isBefore(now) ||
        currentDate.isAtSameMomentAs(_normalizeDate(now))) {
      currentWeek.add(currentDate);

      if (currentDate.weekday == DateTime.sunday ||
          currentDate.isAtSameMomentAs(_normalizeDate(now))) {
        weeks.add(List.from(currentWeek));
        currentWeek.clear();
      }

      currentDate = currentDate.add(const Duration(days: 1));
    }

    const cellSize = 12.0;
    const cellSpacing = 3.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Weekday labels
        Row(
          children: [
            const SizedBox(width: cellSize + cellSpacing),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWeekdayLabel('Mon'),
                const SizedBox(height: cellSize + cellSpacing),
                _buildWeekdayLabel('Wed'),
                const SizedBox(height: cellSize + cellSpacing),
                _buildWeekdayLabel('Fri'),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Heatmap grid
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: weeks.map((week) {
            return Padding(
              padding: const EdgeInsets.only(right: cellSpacing),
              child: Column(
                children: week.map((date) {
                  final count = data[date] ?? 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: cellSpacing),
                    child: _buildCell(date, count, cellSize),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWeekdayLabel(String label) {
    return SizedBox(
      height: 12,
      child: Text(
        label,
        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
      ),
    );
  }

  /// Build a single cell in the heatmap
  Widget _buildCell(DateTime date, int count, double size) {
    final color = _getColorForCount(count);
    final dateStr = DateFormat('MMM d, yyyy').format(date);

    return Tooltip(
      message: '$count completed on $dateStr',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: Colors.grey[300]!, width: 0.5),
        ),
      ),
    );
  }

  /// Get color based on completion count
  Color _getColorForCount(int count) {
    if (count == 0) return Colors.grey[200]!;
    if (count <= 2) return Colors.green[200]!;
    if (count <= 4) return Colors.green[400]!;
    if (count <= 6) return Colors.green[600]!;
    return Colors.green[800]!;
  }

  /// Build legend
  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('Less', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(width: 4),
        _buildLegendCell(Colors.grey[200]!),
        _buildLegendCell(Colors.green[200]!),
        _buildLegendCell(Colors.green[400]!),
        _buildLegendCell(Colors.green[600]!),
        _buildLegendCell(Colors.green[800]!),
        const SizedBox(width: 4),
        Text('More', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildLegendCell(Color color) {
    return Container(
      width: 12,
      height: 12,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: Colors.grey[300]!, width: 0.5),
      ),
    );
  }

  /// Get completion data from logs
  Future<Map<DateTime, int>> _getCompletionData() async {
    final repository = ref.read(taskLogRepositoryProvider);
    final logs = await repository.getAllLogs();

    final completionMap = <DateTime, int>{};

    for (final log in logs) {
      if (log.action == TaskLogAction.completed) {
        final date = _normalizeDate(log.timestamp);
        completionMap[date] = (completionMap[date] ?? 0) + 1;
      }
    }

    return completionMap;
  }

  /// Normalize date to midnight
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
