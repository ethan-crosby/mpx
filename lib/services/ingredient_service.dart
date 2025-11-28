import '../models/ingredient.dart';
import '../repositories/spoonacular_repository.dart';

class IngredientService {
  final SpoonacularRepository repository;

  IngredientService(this.repository);

  Future<List<Ingredient>> searchIngredients({
    required String query,
    int number = 10,
  }) async {
    try {
      final results = await repository.searchIngredients(
        query: query,
        number: number,
      );

      return results
          .map((item) => Ingredient.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to search ingredients: $e');
    }
  }

  Future<Ingredient?> getIngredientById(int ingredientId) async {
    try {
      final results = await repository.searchIngredients(
        query: '',
        number: 100,
      );

      for (final item in results) {
        final ingredient = Ingredient.fromJson(item as Map<String, dynamic>);
        if (ingredient.id == ingredientId) {
          return ingredient;
        }
      }

      return null;
    } catch (e) {
      throw Exception('Failed to get ingredient by ID: $e');
    }
  }
}

