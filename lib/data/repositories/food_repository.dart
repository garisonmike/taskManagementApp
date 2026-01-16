import '../../domain/entities/food_entity.dart';
import '../../domain/entities/food_nutrition_value_entity.dart';
import '../../domain/entities/nutrition_column_entity.dart';
import '../datasources/local/food_local_data_source.dart';
import '../datasources/local/food_nutrition_value_local_data_source.dart';
import '../datasources/local/nutrition_column_local_data_source.dart';
import '../models/food_model.dart';
import '../models/food_nutrition_value_model.dart';
import '../models/nutrition_column_model.dart';

class FoodRepository {
  final FoodLocalDataSource _foodDataSource;
  final NutritionColumnLocalDataSource _columnDataSource;
  final FoodNutritionValueLocalDataSource _valueDataSource;

  FoodRepository(
    this._foodDataSource,
    this._columnDataSource,
    this._valueDataSource,
  );

  // Food operations
  Future<int> createFood(FoodEntity food) async {
    final model = FoodModel.fromEntity(food);
    return await _foodDataSource.createFood(model);
  }

  Future<FoodEntity?> getFoodById(int id) async {
    final model = await _foodDataSource.getFoodById(id);
    return model?.toEntity();
  }

  Future<List<FoodEntity>> getAllFoods() async {
    final models = await _foodDataSource.getAllFoods();
    return models.map((model) => model.toEntity()).toList();
  }

  Future<List<FoodEntity>> searchFoods(String query) async {
    final models = await _foodDataSource.searchFoods(query);
    return models.map((model) => model.toEntity()).toList();
  }

  Future<int> updateFood(FoodEntity food) async {
    final model = FoodModel.fromEntity(food);
    return await _foodDataSource.updateFood(model);
  }

  Future<int> deleteFood(int id) async {
    // Delete associated nutrition values first (cascade)
    await _valueDataSource.deleteValuesByFoodId(id);
    return await _foodDataSource.deleteFood(id);
  }

  // Nutrition column operations
  Future<int> createColumn(NutritionColumnEntity column) async {
    final model = NutritionColumnModel.fromEntity(column);
    return await _columnDataSource.createColumn(model);
  }

  Future<NutritionColumnEntity?> getColumnById(int id) async {
    final model = await _columnDataSource.getColumnById(id);
    return model?.toEntity();
  }

  Future<List<NutritionColumnEntity>> getAllColumns() async {
    final models = await _columnDataSource.getAllColumns();
    return models.map((model) => model.toEntity()).toList();
  }

  Future<int> updateColumn(NutritionColumnEntity column) async {
    final model = NutritionColumnModel.fromEntity(column);
    return await _columnDataSource.updateColumn(model);
  }

  Future<int> deleteColumn(int id) async {
    // Delete associated values first (cascade)
    await _valueDataSource.deleteValuesByColumnId(id);
    return await _columnDataSource.deleteColumn(id);
  }

  // Food nutrition value operations
  Future<int> createValue(FoodNutritionValueEntity value) async {
    final model = FoodNutritionValueModel.fromEntity(value);
    return await _valueDataSource.createValue(model);
  }

  Future<FoodNutritionValueEntity?> getValueById(int id) async {
    final model = await _valueDataSource.getValueById(id);
    return model?.toEntity();
  }

  Future<List<FoodNutritionValueEntity>> getValuesByFoodId(int foodId) async {
    final models = await _valueDataSource.getValuesByFoodId(foodId);
    return models.map((model) => model.toEntity()).toList();
  }

  Future<List<FoodNutritionValueEntity>> getValuesByColumnId(
    int columnId,
  ) async {
    final models = await _valueDataSource.getValuesByColumnId(columnId);
    return models.map((model) => model.toEntity()).toList();
  }

  Future<int> updateValue(FoodNutritionValueEntity value) async {
    final model = FoodNutritionValueModel.fromEntity(value);
    return await _valueDataSource.updateValue(model);
  }

  Future<int> deleteValue(int id) async {
    return await _valueDataSource.deleteValue(id);
  }
}
