import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';

class RecipeVM extends ChangeNotifier {
	final RecipeService _service;

	RecipeVM(
		this._service
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

		print('Working');
	}

	@override
	void dispose() {
		super.dispose();
	}
}
