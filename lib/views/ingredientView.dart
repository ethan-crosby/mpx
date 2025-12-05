import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../viewModels/ingredientVM.dart';
import '../widgets/ingredientTileWidget.dart';

class IngredientView extends StatefulWidget {
	const IngredientView({
		super.key,
	});

	@override
	State<IngredientView> createState() => _IngredientView();
}

class _IngredientView extends State<IngredientView> {
	@override
	void initState() {
		super.initState();
	}

	@override
	Widget build(BuildContext context) {
		return CupertinoPageScaffold(
			child: CustomScrollView(
				slivers: [
					const CupertinoSliverNavigationBar(
						largeTitle: Text('Ingredients'),
						trailing: CupertinoButton(
							padding: EdgeInsets.zero,
							onPressed: () {
							},
							child: const Icon(CupertinoIcons.add),
						),
					),

					SliverSafeArea(
						top: false,
						sliver: SliverList(
							delegate: SliverChildBuilderDelegate(
								(context, index) {
									final vm = context.watch<IngredientVM>();
									final ingredient = vm.ingredients[index];

									return IngredientTileWidget(
										index: index,
										ingredient: ingredient,
									);
								},
								childCount: context.watch<IngredientVM>().ingredients.length,
							),
						),
					),
				],
			),
		);
	}
}