import '../models/nutrient.dart';
import '../repositories/spoonacular_repository.dart';

class NutritionService {
	final SpoonacularRepository repository;

	NutritionService(this.repository);

	Future<List<Nutrient>> getNutritionFacts({
		required int id,
	}) async {
		try {
			final result = await repository.getIngredientInformation(id);

			final map = result as Map<String, dynamic>;

			final nutrition = map['nutrition'] as Map<String, dynamic>;
			final nutrientsJson = nutrition['nutrients'] as List<dynamic>;

			return nutrientsJson
					.map((n) => Nutrient.fromJson(n as Map<String, dynamic>))
					.toList();
		} catch (e) {
			throw Exception('Failed to get nutrition facts: $e');
		}
	}
}
