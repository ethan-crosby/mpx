import 'package:flutter/cupertino.dart';

import '../models/recipe.dart';

class RecipeDetailView extends StatelessWidget {
	final Recipe recipe;

	const RecipeDetailView({
		super.key,
		required this.recipe,
	});

	@override
	Widget build(BuildContext context) {
		return CupertinoPageScaffold(
			navigationBar: CupertinoNavigationBar(
				middle: Text(recipe.title),
			),
			child: SafeArea(
				child: SingleChildScrollView(
					padding: const EdgeInsets.all(16),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							if (recipe.image != null)
								Image.network(
									recipe.image!,
									width: double.infinity,
									height: 200,
									fit: BoxFit.cover,
								)
							else
								const Icon(
									CupertinoIcons.photo,
									size: 100,
									color: CupertinoColors.systemGrey,
								),
							const SizedBox(height: 16),

							Text(
								recipe.title,
								style: const TextStyle(
									fontSize: 24,
									fontWeight: FontWeight.bold,
								),
							),
							const SizedBox(height: 8),

							Row(
								children: [
									const Icon(
										CupertinoIcons.heart_fill,
										color: CupertinoColors.systemRed,
									),
									const SizedBox(width: 6),
									Text(
										(recipe.likes ?? 0).toString(),
										style: const TextStyle(fontSize: 16),
									),
								],
							),
							const SizedBox(height: 16),

							if (recipe.usedIngredients != null &&
									recipe.usedIngredients!.isNotEmpty)
								Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										const Text(
											'Used Ingredients:',
											style: TextStyle(
												fontSize: 18,
												fontWeight: FontWeight.bold,
											),
										),
										const SizedBox(height: 4),
										...recipe.usedIngredients!
												.map((i) => Text('- ${i.name}'))
												.toList(),
										const SizedBox(height: 16),
									],
								),

							if (recipe.missedIngredients != null &&
									recipe.missedIngredients!.isNotEmpty)
								Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										const Text(
											'Missed Ingredients:',
											style: TextStyle(
												fontSize: 18,
												fontWeight: FontWeight.bold,
											),
										),
										const SizedBox(height: 4),
										...recipe.missedIngredients!
												.map((i) => Text('- ${i.name}'))
												.toList(),
										const SizedBox(height: 16),
									],
								),

							Text(
								'Used Ingredient Count: ${recipe.usedIngredientCount ?? 0}',
							),
							Text(
								'Missed Ingredient Count: ${recipe.missedIngredientCount ?? 0}',
							),
						],
					),
				),
			),
		);
	}
}