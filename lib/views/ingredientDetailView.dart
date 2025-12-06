import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../viewModels/ingredientDetailVM.dart';
import '../widgets/ingredientSearchTileWidget.dart';
import '../models/ingredient.dart';
import '../models/nutrient.dart';

class IngredientDetailView extends StatelessWidget {
	final Ingredient ingredient;

	const IngredientDetailView({
		super.key,
		required this.ingredient,
	});

	@override
	Widget build(BuildContext context) {
		return CupertinoPageScaffold(
			navigationBar: CupertinoNavigationBar(
				middle: Text(ingredient.name),
			),
			child: SafeArea(
				child: Container(
					child: context.watch<IngredientDetailVM>().loading ? Text('Loading') : Text('Test'),
				),
			),
		);
	}
}