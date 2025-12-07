import '../models/ingredient.dart';
import '../repositories/spoonacular_repository.dart';

class ClassifyService {
	final SpoonacularRepository repository;

	ClassifyService(this.repository);

	Future<Ingredient?> classify({
		required String title,
	}) async {
		try {
			final result = await repository.classifyProductCategory(
				title: title,
			);

			if (result == null) {
				return null;
			}

			final finalIngredient = await repository.searchIngredients(
				query: result,
				number: 1,
			);

			return Ingredient.fromJson(finalIngredient[0] as Map<String, dynamic>);
		} catch (e) {
			print('Failed to classify ingredients: $e');
			return null;
		}
	}
}