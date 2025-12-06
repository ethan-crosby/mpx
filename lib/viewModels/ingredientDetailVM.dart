import 'package:flutter/foundation.dart';

import '../models/nutrient.dart';
import '../services/nutrition_service.dart';
import '../models/ingredient.dart';

class IngredientDetailVM extends ChangeNotifier {
	final NutritionService _service;
	final Ingredient _ingredient;

	IngredientDetailVM(
		this._service,
		this._ingredient,
	) {
		init();
	}

	bool _loading = true;
	bool get loading => _loading;

	List<Nutrient> _nutrients = [];
	List<Nutrient> get nutrients => _nutrients;

	void init() async {
		_nutrients = await _service.getNutritionFacts(
			ingredient: _ingredient,
		);

		_loading = false;
		notifyListeners();
	}

	void refresh() async {
		_loading = true;
		notifyListeners();
		
		_nutrients = await _service.getNutritionFacts(
			ingredient: _ingredient,
		);

		_loading = false;
		notifyListeners();
	}
}