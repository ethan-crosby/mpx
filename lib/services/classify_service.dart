import '../models/ingredient.dart';
import '../repositories/spoonacular_repository.dart';

class ClassifyService {
	final SpoonacularRepository repository;

	ClassifyService(this.repository);

	Future<Ingredient> classify({
		required String title,
	}) async {
		try {
			final result = await repository.classifyProduct(
				title: title,
			);

			//final classification = 

			final finalIngredient = await repository.searchIngredients(
				query: 'query',
				number: 1,
			);

			return Ingredient.fromJson(finalIngredient[0] as Map<String, dynamic>);
			
		} catch (e) {
			throw Exception('Failed to classify ingredients: $e');
		}
	}
}