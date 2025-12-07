import 'package:flutter/cupertino.dart';

import '../models/recipe.dart';
import '../views/recipeDetailView.dart';

class RecipeTileWidget extends StatelessWidget {
	final int index;
	final Recipe recipe;

	RecipeTileWidget({
		super.key,
		required this.index,
		required this.recipe,
	});

	@override
	Widget build(BuildContext context) {
		final isEven = index % 2 == 0;

		return Container(
			padding: EdgeInsets.all(5),
			color: isEven ?
				CupertinoColors.systemBackground.resolveFrom(context) :
				CupertinoColors.systemGrey6.resolveFrom(context),
			child: CupertinoListTile(
				title: Text(
					recipe.title,
					maxLines: 2,
				),
				subtitle: Row(
					mainAxisSize: MainAxisSize.min,
					children: [
						const Icon(
							CupertinoIcons.heart_fill,
							size: 15,
							color: CupertinoColors.destructiveRed,
						),
						const SizedBox(width: 6),
						Text(
							recipe.likes.toString(),
						),
					],
				),
				trailing: const Icon(CupertinoIcons.forward),
				onTap: () {
					Navigator.of(context).push(
						CupertinoPageRoute(
							builder: (_) => RecipeDetailView(
								recipe: recipe,
							),
						),
					);
				},
			),
		);
	}
}
