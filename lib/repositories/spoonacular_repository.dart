import 'dart:convert';
import 'package:http/http.dart' as http;

class SpoonacularRepository {
	final String apiKey;
	final String baseUrl = 'https://api.spoonacular.com';
	final http.Client client;

	SpoonacularRepository({
		required this.apiKey,
		http.Client? client,
	}) : client = client ?? http.Client();

	Future<Map<String, dynamic>> _get(
		String endpoint, {
		Map<String, String>? queryParameters,
	}) async {
		final uri = Uri.parse('$baseUrl$endpoint').replace(
			queryParameters: {
				...?queryParameters,
				'apiKey': apiKey,
			},
		);

		try {
			final response = await client.get(uri);

			if (response.statusCode == 200) {
				return json.decode(response.body) as Map<String, dynamic>;
			} else if (response.statusCode == 401) {
				throw Exception('Invalid API key - Status: ${response.statusCode}, Body: ${response.body}');
			} else if (response.statusCode == 402) {
				throw Exception('API quota exceeded - Status: ${response.statusCode}, Body: ${response.body}');
			} else if (response.statusCode == 404) {
				throw Exception('Resource not found - Status: ${response.statusCode}, Body: ${response.body}');
			} else {
				throw Exception(
					'Failed to load data: ${response.statusCode} - ${response.body}',
				);
			}
		} catch (e) {
			if (e is Exception) rethrow;
			throw Exception('Network error: $e');
		}
	}

	Future<List<dynamic>> _getList(
		String endpoint, {
		Map<String, String>? queryParameters,
	}) async {
		final uri = Uri.parse('$baseUrl$endpoint').replace(
			queryParameters: {
				...?queryParameters,
				'apiKey': apiKey,
			},
		);

		try {
			final response = await client.get(uri);

		if (response.statusCode == 200) {
			return json.decode(response.body) as List<dynamic>;
		} else if (response.statusCode == 401) {
			throw Exception('Invalid API key - Status: ${response.statusCode}, Body: ${response.body}');
		} else if (response.statusCode == 402) {
			throw Exception('API quota exceeded - Status: ${response.statusCode}, Body: ${response.body}');
		} else if (response.statusCode == 404) {
			throw Exception('Resource not found - Status: ${response.statusCode}, Body: ${response.body}');
		} else {
			throw Exception(
				'Failed to load data: ${response.statusCode} - ${response.body}',
			);
		}
		} catch (e) {
			if (e is Exception) rethrow;
			throw Exception('Network error: $e');
		}
	}

	Future<Map<String, dynamic>> _post(
		String endpoint, {
		Map<String, String>? queryParameters,
	}) async {
		final uri = Uri.parse('$baseUrl$endpoint').replace(
			queryParameters: {
				'apiKey': apiKey,
			},
		);

		try {
			final response = await client.post(
				uri,
				headers: {'Content-Type': 'application/json'},
				body: jsonEncode(queryParameters ?? {}),
			);

			if (response.statusCode == 200) {
				return json.decode(response.body) as Map<String, dynamic>;
			} else if (response.statusCode == 401) {
				throw Exception('Invalid API key - Status: ${response.statusCode}, Body: ${response.body}');
			} else if (response.statusCode == 402) {
				throw Exception('API quota exceeded - Status: ${response.statusCode}, Body: ${response.body}');
			} else if (response.statusCode == 404) {
				throw Exception('Resource not found - Status: ${response.statusCode}, Body: ${response.body}');
			} else {
				throw Exception(
					'Failed to load data: ${response.statusCode} - ${response.body}',
				);
			}
		} catch (e) {
			if (e is Exception) rethrow;
			throw Exception('Network error: $e');
		}
	}

	Future<Map<String, dynamic>> getProductByUPC(String upc) async {
		return await _get('/food/products/upc/$upc');
	}

	Future<List<dynamic>> searchIngredients({
		required String query,
		int number = 10,
	}) async {
		final data = await _getList(
			'/food/ingredients/autocomplete',
			queryParameters: {
				'query': query,
				'number': number.toString(),
				'metaInformation': 'true',
			},
		);
		if (data.isNotEmpty) {
			return data as List<dynamic>;
		} else {
			return [];
		}
	}

	Future<List<dynamic>> classifyProduct({
		required String title,
	}) async {
		final data = await _post(
			'/food/products/classify',
			queryParameters: {
				'title': title,
			},
		);
		if (data.isNotEmpty) {
			return data as List<dynamic>;
		} else {
			return [];
		}
	}

	Future<List<dynamic>> getRecipesByIngredients({
		required String ingredients,
		int number = 10,
		int ranking = 1,
	}) async {
		return await _getList(
			'/recipes/findByIngredients',
			queryParameters: {
				'ingredients': ingredients,
				'number': number.toString(),
				'ranking': ranking.toString(),
			},
		);
	}

	Future<Map<String, dynamic>> getIngredientInformation({
		required int id,
		required double amount,
		required String unit,
	}) async {
		return await _get(
			'/food/ingredients/$id/information',
			queryParameters: {
				'amount': amount.toString(),
				'unit': unit,
			},
		);
	}

	Future<Map<String, dynamic>> getRecipeInformation(int recipeId) async {
		return await _get('/recipes/$recipeId/information');
	}
}

