import '../models/recipe.dart';
import '../repositories/spoonacular_repository.dart';

class RecipeService {
	final SpoonacularRepository repository;

	RecipeService(this.repository);

	Future<List<Recipe>> getRecipesByIngredients({
		required List<String> ingredients,
		int number = 10,
		int ranking = 1,
	}) async {
		try {
			final ingredientsString = ingredients.join(',');

			final results = await repository.getRecipesByIngredients(
				ingredients: ingredientsString,
				number: number,
				ranking: ranking,
			);

			return results
					.map((item) => Recipe.fromJson(item as Map<String, dynamic>))
					.toList();
		} catch (e) {
			throw Exception('Failed to get recipes by ingredients: $e');
		}
	}

	Future<Recipe> getRecipeDetails(int recipeId) async {
		try {
			final data = await repository.getRecipeInformation(recipeId);

			return Recipe.fromJson(data);
		} catch (e) {
			throw Exception('Failed to get recipe details: $e');
		}
	}

	List<Recipe> sortBySimilarity(List<Recipe> recipes) {
		final sorted = List<Recipe>.from(recipes);
		sorted.sort((a, b) {
			final usedA = a.usedIngredientCount ?? 0;
			final usedB = b.usedIngredientCount ?? 0;
			if (usedA != usedB) {
				return usedB.compareTo(usedA);
			}
			final missedA = a.missedIngredientCount ?? 0;
			final missedB = b.missedIngredientCount ?? 0;
			return missedA.compareTo(missedB);
		});

		return sorted;
	}
}

