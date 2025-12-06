import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../models/ingredient.dart';
import '../viewModels/ingredientVM.dart';

class IngredientTileWidget extends StatelessWidget {
	final int index;
	final Ingredient ingredient;

	const IngredientTileWidget({
		super.key,
		required this.index,
		required this.ingredient,
	});

	@override
	Widget build(BuildContext context) {
		return LayoutBuilder(
			builder: (context, constraints) {
				return CupertinoContextMenu(
					actions: [
						CupertinoContextMenuAction(
							onPressed: () {
								context.read<IngredientVM>().removeIngredient(ingredient);
								Navigator.pop(context);
							},
							child: const Text('Delete'),
							isDestructiveAction: true,
						),
					],
					child: ConstrainedBox(
						constraints: BoxConstraints(
							minWidth: constraints.maxWidth,
							maxWidth: constraints.maxWidth,
						),
						child: CupertinoListTile(
							title: Text(ingredient.name),
							leading: const Icon(CupertinoIcons.star),
							trailing: const Icon(CupertinoIcons.forward),
							onTap: () {},
						),
					),
				);
			},
		);
	}
}
