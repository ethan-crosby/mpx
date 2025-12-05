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
				// constraints.maxWidth is the REAL width of the sliver item
				return CupertinoContextMenu(
					actions: [
						CupertinoContextMenuAction(
							onPressed: () => Navigator.pop(context),
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
							onTap: () {
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
						),
					),
				);
			},
		);
	}
}
