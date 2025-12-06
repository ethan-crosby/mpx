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

			return Ingredient.fromJson(result as Map<String, dynamic>));
		} catch (e) {
			throw Exception('Failed to search ingredients: $e');
		}
	}
}