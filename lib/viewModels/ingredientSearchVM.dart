import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

import '../models/ingredient.dart';
import '../services/ingredient_service.dart';

class IngredientSearchVM extends ChangeNotifier {
	final IngredientService _service;

	IngredientSearchVM(
		this._service,
	) {
		// init();
	}

	List<Ingredient> _ingredients = [
		Ingredient(
			id: 1,
			name: 'Flour',
		)
	];
	List<Ingredient> get ingredients => _ingredients;
}