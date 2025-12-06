import 'package:flutter/cupertino.dart';

import '../models/ingredient.dart';

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
								Navigator.pop(context);

								context.read<IngredientVM>().removeIngredient(ingredient);
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
