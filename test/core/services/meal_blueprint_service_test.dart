import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:task_management_app/core/services/meal_blueprint_service.dart';
import 'package:task_management_app/data/datasources/local/blueprint_meal_local_data_source.dart';
import 'package:task_management_app/data/datasources/local/database_helper.dart';
import 'package:task_management_app/data/datasources/local/meal_blueprint_local_data_source.dart';
import 'package:task_management_app/data/datasources/local/meal_substitution_local_data_source.dart';
import 'package:task_management_app/data/repositories/meal_blueprint_repository.dart';
import 'package:task_management_app/domain/entities/blueprint_meal_entity.dart';
import 'package:task_management_app/domain/entities/meal_blueprint_entity.dart';
import 'package:task_management_app/domain/entities/meal_entity.dart';
import 'package:task_management_app/domain/entities/meal_substitution_entity.dart';
import 'package:task_management_app/domain/entities/meal_timeline_entry.dart';

void main() {
  late DatabaseHelper dbHelper;
  late MealBlueprintLocalDataSource blueprintDataSource;
  late BlueprintMealLocalDataSource blueprintMealDataSource;
  late MealSubstitutionLocalDataSource substitutionDataSource;
  late MealBlueprintRepository repository;
  late MealBlueprintService service;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    final testDbName =
        'test_meal_blueprint_${DateTime.now().millisecondsSinceEpoch}.db';
    dbHelper = DatabaseHelper.test(testDbName);
    blueprintDataSource = MealBlueprintLocalDataSource(dbHelper);
    blueprintMealDataSource = BlueprintMealLocalDataSource(dbHelper);
    substitutionDataSource = MealSubstitutionLocalDataSource(dbHelper);
    repository = MealBlueprintRepository(
      blueprintDataSource,
      blueprintMealDataSource,
      substitutionDataSource,
    );
    service = MealBlueprintService(repository);
  });

  tearDown(() async {
    await dbHelper.close();
    await dbHelper.deleteDb();
  });

  test('weekly timeline uses blueprint meals', () async {
    final now = DateTime(2026, 1, 12); // Monday
    final blueprint = MealBlueprintEntity(
      id: 'blueprint-1',
      name: 'Weekly Plan',
      description: null,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    await repository.createBlueprint(blueprint);

    final mondayBreakfast = BlueprintMealEntity(
      id: 'meal-1',
      blueprintId: blueprint.id,
      dayOfWeek: DayOfWeek.monday,
      mealType: MealType.breakfast,
      mealName: 'Oatmeal',
      description: 'With berries',
      createdAt: now,
    );

    final tuesdayLunch = BlueprintMealEntity(
      id: 'meal-2',
      blueprintId: blueprint.id,
      dayOfWeek: DayOfWeek.tuesday,
      mealType: MealType.lunch,
      mealName: 'Salad',
      description: null,
      createdAt: now,
    );

    await repository.createBlueprintMeal(mondayBreakfast);
    await repository.createBlueprintMeal(tuesdayLunch);

    final entries = await service.getWeeklyTimeline(
      blueprintId: blueprint.id,
      weekStart: now,
    );

    expect(entries.length, 2);
    expect(
      entries.any(
        (e) =>
            e.dayOfWeek == DayOfWeek.monday &&
            e.mealType == MealType.breakfast &&
            e.source == MealTimelineSource.blueprint,
      ),
      true,
    );
    expect(
      entries.any(
        (e) =>
            e.dayOfWeek == DayOfWeek.tuesday &&
            e.mealType == MealType.lunch &&
            e.source == MealTimelineSource.blueprint,
      ),
      true,
    );
  });

  test('substitution overrides without altering blueprint', () async {
    final now = DateTime(2026, 1, 12); // Monday
    final blueprint = MealBlueprintEntity(
      id: 'blueprint-2',
      name: 'Weekly Plan',
      description: null,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    await repository.createBlueprint(blueprint);

    final mondayBreakfast = BlueprintMealEntity(
      id: 'meal-3',
      blueprintId: blueprint.id,
      dayOfWeek: DayOfWeek.monday,
      mealType: MealType.breakfast,
      mealName: 'Oatmeal',
      description: null,
      createdAt: now,
    );

    await repository.createBlueprintMeal(mondayBreakfast);

    final substitution = MealSubstitutionEntity(
      id: 'sub-1',
      blueprintId: blueprint.id,
      date: now,
      dayOfWeek: DayOfWeek.monday,
      mealType: MealType.breakfast,
      mealName: 'Pancakes',
      description: null,
      createdAt: now,
    );

    await repository.createSubstitution(substitution);

    final entries = await service.getWeeklyTimeline(
      blueprintId: blueprint.id,
      weekStart: now,
    );

    final entry = entries.firstWhere(
      (e) =>
          e.dayOfWeek == DayOfWeek.monday && e.mealType == MealType.breakfast,
    );

    expect(entry.mealName, 'Pancakes');
    expect(entry.source, MealTimelineSource.substitution);

    final blueprintMeals = await repository.getMealsByBlueprintId(blueprint.id);
    expect(blueprintMeals.first.mealName, 'Oatmeal');
  });
}
