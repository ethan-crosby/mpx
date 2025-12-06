import '../models/product.dart';
import '../models/ingredient.dart';
import '../repositories/spoonacular_repository.dart';

class UPCService {
	final SpoonacularRepository repository;

	UPCService(this.repository);

	Future<Product> getProductByUPC(String upc) async {
		try {
			final data = await repository.getProductByUPC(upc);

			// Parse id safely
			int id = 0;
			if (data['id'] != null) {
				if (data['id'] is int) {
					id = data['id'] as int;
				} else if (data['id'] is num) {
					id = (data['id'] as num).toInt();
				} else {
					id = int.tryParse(data['id'].toString()) ?? 0;
				}
			}

			final title = (data['title'] as String?) ?? 'Unknown Product';
			final image = data['image'] as String?;

			// Breadcrumbs can be String or List
			final breadcrumbs = data['breadcrumbs'] != null
				? (data['breadcrumbs'] is String
					? data['breadcrumbs'] as String
					: (data['breadcrumbs'] as List).join(', '))
				: null;

			final brand = data['brand'] as String?;
			final upcValue = data['upc'] as String? ?? upc;

			// Safely parse servings and price as Map<String, dynamic> if possible
			Map<String, dynamic>? servings;
			if (data['servings'] is Map<String, dynamic>) {
				servings = data['servings'] as Map<String, dynamic>;
			}

			Map<String, dynamic>? price;
			if (data['price'] is Map<String, dynamic>) {
				price = data['price'] as Map<String, dynamic>;
			}

			// Parse ingredients safely
			List<Ingredient>? ingredients;
			if (data['ingredients'] != null && data['ingredients'] is List) {
				try {
					final ingredientsList = data['ingredients'] as List;
					ingredients = ingredientsList
						.where((e) => e != null)
						.map((e) {
							if (e is Map<String, dynamic>) {
								return Ingredient.fromJson(e);
							} else {
								return Ingredient(id: 0, name: e.toString());
							}
						})
						.toList();
				} catch (_) {
					// ignore parsing errors
				}
			}

			// Fallback if ingredients list is empty
			if ((ingredients == null || ingredients.isEmpty) &&
				data['ingredientList'] != null) {
				final ingredientListStr = data['ingredientList'] as String?;
				if (ingredientListStr != null && ingredientListStr.isNotEmpty) {
					final names = ingredientListStr
						.split(',')
						.map((s) => s.trim())
						.where((s) => s.isNotEmpty)
						.toList();
					ingredients = names
						.map((name) => Ingredient(id: 0, name: name))
						.toList();
				}
			}

			return Product(
				id: id,
				title: title,
				image: image,
				upc: upcValue,
				breadcrumbs: breadcrumbs,
				brand: brand,
				ingredients: ingredients,
				servings: servings,
				price: price,
			);
		} catch (e) {
			throw Exception('Failed to get product by UPC: $e');
		}
	}

	Future<List<String>> getIngredientsFromUPC(String upc) async {
		final product = await getProductByUPC(upc);

		if (product.ingredients == null || product.ingredients!.isEmpty) {
			return [];
		}

		return product.ingredients!
			.map((ingredient) => ingredient.name)
			.where((name) => name.isNotEmpty)
			.toList();
	}
}
