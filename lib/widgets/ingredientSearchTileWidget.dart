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
		return CupertinoContextMenu(
			actions: [
				CupertinoContextMenuAction(
					onPressed: () => Navigator.pop(context),
					child: const Text('Delete'),
					isDestructiveAction: true,
				),
			],
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
		);
	}
}
