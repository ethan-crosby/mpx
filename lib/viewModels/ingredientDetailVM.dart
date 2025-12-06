import 'package:flutter/foundation.dart';

import '../models/nutrient.dart';
import '../services/nutrition_service.dart';

class IngredientDetailVM extends ChangeNotifier {
	final NutritionService _service;

	IngredientDetailVM(
		this._service,
	) {
		init();
	}

	bool _loading = true;
	bool get loading => _loading;

	List<Nutrient> _nutrients = [];
	List<Nutrient> get nutrients => _nutrients;

	void init() async {

	}
}