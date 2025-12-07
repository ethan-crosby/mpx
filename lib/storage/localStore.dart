import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/ingredient.dart';

class LocalStore {
	static const _kIngredients = 'ingredients';

	Future<List<Ingredient>> readIngredients() async {
		final prefs = await SharedPreferences.getInstance();
		final raw = prefs.getString(_kIngredients);
		if (raw == null) {
			return [];
		}
		final List list = jsonDecode(raw) as List;
		return list.map((e) => Ingredient.fromJson(e as Map<String, dynamic>)).toList();
	}

	Future<void> writeIngredients(List<Ingredient> ingredient) async {
		final prefs = await SharedPreferences.getInstance();
		final encoded = jsonEncode(ingredient.map((e) => e.toJson()).toList());
		await prefs.setString(_kIngredients, encoded);
	}
}