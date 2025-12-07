import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../models/ingredient.dart';
import '../services/ingredient_service.dart';

class IngredientSearchVM extends ChangeNotifier {
	final IngredientService _service;

	IngredientSearchVM(this._service);

	List<Ingredient> _ingredients = [];
	List<Ingredient> get ingredients => _ingredients;

	Timer? _debounce;

	bool _loading = false;
	bool get loading => _loading;

	void search(String query) {
		_loading = true;
		notifyListeners();

		_debounce?.cancel();

		_debounce = Timer(const Duration(milliseconds: 300), () async {
			try {
				await _searchAsync(query);
			} catch (e) {
				print('Search failed. Did you navigate away?');
			}
		});
	}

	Future<void> _searchAsync(String query) async {
		try {
			if (query.isEmpty) {
				_ingredients = [];
				_loading = false;
				notifyListeners();
				return;
			}

			_ingredients = await compute(_searchInBackground, {'service': _service, 'query': query});
			notifyListeners();
		} catch (e) {
			print('Error: $e');
		}

		_loading = false;
		notifyListeners();
	}

	// Runs in background isolate
	static Future<List<Ingredient>> _searchInBackground(Map<String, dynamic> params) async {
		final IngredientService service = params['service'];
		final String query = params['query'];
		return await service.searchIngredients(query: query);
	}

	@override
	void dispose() {
		_debounce?.cancel();
		super.dispose();
	}
}
