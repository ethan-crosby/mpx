import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../models/ingredient.dart';
import '../viewModels/ingredientVM.dart';
import '../viewModels/ingredientDetailVM.dart';
import '../views/ingredientDetailView.dart';
import '../services/nutrition_service.dart';
import '../repositories/spoonacular_repository.dart';

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
		final isEven = index % 2 == 0;

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
						child: Container(
							child: CupertinoListTile(
								title: Text(ingredient.name),
								subtitle: Row(
									children: [
										Text(
											(ingredient.amount ?? '0.0').toString(),
										),
										Text(
											' ${ingredient.unit ?? 'g'}',
										),
									],
								),
								trailing: const Icon(CupertinoIcons.forward),
								onTap: () {
									Navigator.of(context).push(
										CupertinoPageRoute(
											builder: (_) => MultiProvider(
												providers: [
													ProxyProvider<SpoonacularRepository, NutritionService>(
														update: (_, repo, __) => NutritionService(repo),
													),
													ChangeNotifierProvider<IngredientDetailVM>(
														create: (context) => IngredientDetailVM(
															context.read<NutritionService>(),
															ingredient,
														),
													),
												],
												child: IngredientDetailView(
													ingredient: ingredient,
												),
											),
										),
									);
								},
							),
							color: isEven ?
								CupertinoColors.systemBackground.resolveFrom(context) :
								CupertinoColors.systemGrey6.resolveFrom(context),
						),
					),
				);
			},
		);
	}
}
