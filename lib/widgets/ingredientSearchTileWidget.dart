import 'package:flutter/cupertino.dart';

import '../models/ingredient.dart';

class IngredientSearchTileWidget extends StatelessWidget {
	final int index;
	final Ingredient ingredient;

	IngredientSearchTileWidget({
		super.key,
		required this.index,
		required this.ingredient,
	});

	@override
	Widget build(BuildContext context) {
		return CupertinoListTile(
			title: Text(ingredient.name),
			onTap: () {
				Navigator.pop(context, ingredient);

				/*
				showCupertinoDialog(
					context: context,
					builder: (_) => CupertinoAlertDialog(
						title: Text('Tapped on item $index'),
						actions: [
							CupertinoDialogAction(
								child: const Text('OK'),
								onPressed: () => Navigator.pop(context),
							),
						],
					),
				);
				*/
			},
		);
	}
}
