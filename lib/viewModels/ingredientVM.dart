import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

import '../models/ingredient.dart';
import '../services/ingredient_service.dart';

class IngredientVM extends ChangeNotifier {
	final IngredientService _service;

	IngredientVM(
		this._service,
	) {
		// init();
	}

	List<Ingredient> _ingredients = [];
	List<Ingredient> get ingredients => _ingredients;

	void addIngredient(Ingredient ingredient) {
		_ingredients.add(ingredient);
		notifyListeners();
	}

	void removeIngredient(Ingredient ingredient) {
		_ingredients.remove(ingredient);
		notifyListeners();
	}
}