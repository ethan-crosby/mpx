import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import '../models/recipe.dart';
import '../models/ingredient.dart';
import '../services/recipe_service.dart';

class RecipeVM extends ChangeNotifier {
	final RecipeService _service;
	final List<Ingredient> _ingredients;

	RecipeVM(
		this._service,
		this._ingredients,
	) {
		init();
	}

	List<Recipe> _recipes = [];
	List<Recipe> get recipes => _recipes;

	bool _loading = false;
	bool get loading => _loading;

	void init() async {
		_loading = true;
		notifyListeners();

		try {
			_recipes = await _service.getRecipesByIngredients(
				ingredients: _ingredients.map((obj) => obj.name).toList(),
			);
		} catch (e) {
			throw Exception('Failed to search recipes: $e');
		}

		_loading = false;
		notifyListeners();
	}

	@override
	void dispose() {
		super.dispose();
	}
}
