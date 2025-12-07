import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

import '../models/ingredient.dart';
import '../services/ingredient_service.dart';
import '../storage/localStore.dart';

class IngredientVM extends ChangeNotifier {
	final IngredientService _service;
	final LocalStore _store;

	IngredientVM(
		this._service,
		this._store,
	) {
		init();
	}

	List<Ingredient> _ingredients = [];
	List<Ingredient> get ingredients => _ingredients;

	bool _loading = true;
	bool get loading => _loading;

	void addIngredient(Ingredient ingredient) {
		_loading = true;
		notifyListeners();

		_ingredients.add(ingredient);
		_store.writeIngredients(_ingredients);
		
		_loading = false;
		notifyListeners();
	}

	void removeIngredient(Ingredient ingredient) {
		_loading = true;
		notifyListeners();

		_ingredients.remove(ingredient);
		_store.writeIngredients(_ingredients);

		_loading = false;
		notifyListeners();
	}

	void changeAmount() {
		notifyListeners();
	}

	Future<void> init() async {
		_loading = true;
		notifyListeners();

		_ingredients = await _store.readIngredients();

		_loading = false;
		notifyListeners();
	}
}