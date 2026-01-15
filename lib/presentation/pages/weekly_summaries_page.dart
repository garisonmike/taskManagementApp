import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/weekly_summary_entity.dart';
import '../providers/weekly_summary_provider.dart';

/// Page for viewing weekly summaries
class WeeklySummariesPage extends ConsumerWidget {
  const WeeklySummariesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summariesAsync = ref.watch(weeklySummariesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Summaries'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Generate Summary',
            onPressed: () => _generateSummary(context, ref),
          ),
        ],
      ),
      body: summariesAsync.when(
        data: (summaries) {
          if (summaries.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No summaries yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap + to generate a summary',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: summaries.length,
            itemBuilder: (context, index) {
              final summary = summaries[index];
              return _SummaryCard(summary: summary);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Future<void> _generateSummary(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Summary'),
        content: const Text('Generate a weekly summary for the current week?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Generate'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final service = ref.read(weeklySummaryServiceProvider);
        await service.generateCurrentWeekSummary();

        // Refresh the list
        ref.invalidate(weeklySummariesProvider);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Summary generated successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }
}

/// Card widget to display a weekly summary
class _SummaryCard extends StatelessWidget {
  final WeeklySummaryEntity summary;

  const _SummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Week range
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${dateFormat.format(summary.weekStartDate)} - ${dateFormat.format(summary.weekEndDate)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Completion rate
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Completion Rate', style: theme.textTheme.titleSmall),
                Text(
                  '${summary.completionRate.toStringAsFixed(1)}%',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: _getCompletionRateColor(summary.completionRate),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Progress bar
            LinearProgressIndicator(
              value: summary.completionRate / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getCompletionRateColor(summary.completionRate),
              ),
            ),
            const SizedBox(height: 16),

            // Task breakdown
            Text(
              'Task Breakdown',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildStatRow(
              icon: Icons.task_alt,
              label: 'Total Tasks',
              value: summary.totalTasks,
              color: Colors.blue,
            ),
            _buildStatRow(
              icon: Icons.check_circle,
              label: 'Completed',
              value: summary.completedTasks,
              color: Colors.green,
            ),
            _buildStatRow(
              icon: Icons.cancel,
              label: 'Failed',
              value: summary.failedTasks,
              color: Colors.red,
            ),
            _buildStatRow(
              icon: Icons.schedule,
              label: 'Postponed',
              value: summary.postponedTasks,
              color: Colors.orange,
            ),
            _buildStatRow(
              icon: Icons.delete,
              label: 'Dropped',
              value: summary.droppedTasks,
              color: Colors.purple,
            ),
            _buildStatRow(
              icon: Icons.remove_circle,
              label: 'Deleted',
              value: summary.deletedTasks,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required int value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text(
            value.toString(),
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Color _getCompletionRateColor(double rate) {
    if (rate >= 80) return Colors.green;
    if (rate >= 60) return Colors.orange;
    return Colors.red;
  }
}
