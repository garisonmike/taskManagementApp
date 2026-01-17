import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/meal_entity.dart';
import '../../domain/entities/meal_timeline_entry.dart';
import '../providers/meal_blueprint_provider.dart';

class WellnessPage extends StatelessWidget {
  const WellnessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Wellness'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Meals', icon: Icon(Icons.restaurant_menu)),
              Tab(text: 'Workouts', icon: Icon(Icons.fitness_center)),
            ],
          ),
        ),
        body: const TabBarView(children: [MealsView(), WorkoutsView()]),
      ),
    );
  }
}

class WorkoutsView extends StatelessWidget {
  const WorkoutsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fitness_center, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Workouts module coming soon',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class MealsView extends ConsumerStatefulWidget {
  const MealsView({super.key});

  @override
  ConsumerState<MealsView> createState() => _MealsViewState();
}

class _MealsViewState extends ConsumerState<MealsView> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final activeBlueprintsAsync = ref.watch(activeMealBlueprintsProvider);

    return activeBlueprintsAsync.when(
      data: (blueprints) {
        if (blueprints.isEmpty) {
          return const Center(
            child: Text('No active meal plan. Create one in Blueprints.'),
          );
        }

        final blueprint = blueprints.first;
        final weekStart = _getStartOfWeek(DateTime.now());

        return Column(
          children: [
            _WeekCalendar(
              weekStart: weekStart,
              selectedDate: _selectedDate,
              onDateSelected: (date) {
                setState(() => _selectedDate = date);
              },
            ),
            Expanded(
              child: _MealTimeline(
                blueprintId: blueprint.id,
                weekStart: weekStart,
                selectedDate: _selectedDate,
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }

  DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }
}

class _WeekCalendar extends StatelessWidget {
  final DateTime weekStart;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const _WeekCalendar({
    required this.weekStart,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = weekStart.add(Duration(days: index));
          final isSelected = _isSameDay(date, selectedDate);
          final isToday = _isSameDay(date, DateTime.now());

          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : (isToday ? Colors.blue.withValues(alpha: 0.1) : null),
                borderRadius: BorderRadius.circular(12),
                border: isToday && !isSelected
                    ? Border.all(color: Colors.blue)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : null,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _MealTimeline extends ConsumerWidget {
  final String blueprintId;
  final DateTime weekStart;
  final DateTime selectedDate;

  const _MealTimeline({
    required this.blueprintId,
    required this.weekStart,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineAsync = ref.watch(
      weeklyMealTimelineProvider((
        blueprintId: blueprintId,
        weekStart: weekStart,
      )),
    );

    return timelineAsync.when(
      data: (entries) {
        final dayEntries =
            entries.where((e) {
                return e.date.year == selectedDate.year &&
                    e.date.month == selectedDate.month &&
                    e.date.day == selectedDate.day;
              }).toList()
              ..sort((a, b) => a.mealType.index.compareTo(b.mealType.index));

        if (dayEntries.isEmpty) {
          return const Center(child: Text('No meals scheduled for this day'));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ...dayEntries.map((entry) => _MealTile(entry: entry)),
            const Divider(),
            _IngredientsSection(entries: entries),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }
}

class _MealTile extends StatelessWidget {
  final MealTimelineEntry entry;

  const _MealTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(_getIconForMealType(entry.mealType)),
        title: Text(entry.mealName),
        subtitle: Text(_getMealTypeName(entry.mealType)),
        trailing: entry.source == MealTimelineSource.substitution
            ? const Icon(Icons.swap_horiz, color: Colors.orange)
            : null,
      ),
    );
  }

  IconData _getIconForMealType(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return Icons.breakfast_dining;
      case MealType.lunch:
        return Icons.lunch_dining;
      case MealType.dinner:
        return Icons.dinner_dining;
      case MealType.snack:
        return Icons.icecream;
    }
  }

  String _getMealTypeName(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }
}

class _IngredientsSection extends StatefulWidget {
  final List<MealTimelineEntry> entries;

  const _IngredientsSection({required this.entries});

  @override
  State<_IngredientsSection> createState() => _IngredientsSectionState();
}

class _IngredientsSectionState extends State<_IngredientsSection> {
  final Set<String> _checkedItems = {};

  @override
  Widget build(BuildContext context) {
    // Generate unique meal names as "Ingredients" for now (simple interpretation)
    // In a real app, this would extract ingredients from meals
    final uniqueMeals = widget.entries.map((e) => e.mealName).toSet().toList()
      ..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Weekly Shopping List',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        if (uniqueMeals.isEmpty)
          const Text('No meals planned for this week.')
        else
          ...uniqueMeals.map((meal) {
            final isChecked = _checkedItems.contains(meal);
            return CheckboxListTile(
              title: Text(
                meal,
                style: TextStyle(
                  decoration: isChecked ? TextDecoration.lineThrough : null,
                  color: isChecked ? Colors.grey : null,
                ),
              ),
              value: isChecked,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _checkedItems.add(meal);
                  } else {
                    _checkedItems.remove(meal);
                  }
                });
              },
            );
          }),
      ],
    );
  }
}
