import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../viewModels/ingredientSearchVM.dart';
import '../widgets/ingredientSearchTileWidget.dart';

class IngredientSearchView extends StatefulWidget {
	const IngredientSearchView({
		super.key,
	});

	@override
	State<IngredientSearchView> createState() => _IngredientSearchView();
}

class _IngredientSearchView extends State<IngredientSearchView> {
	@override
	void initState() {
		super.initState();
	}

	@override
	Widget build(BuildContext context) {
		final vm = context.watch<IngredientSearchVM>();

		return CupertinoPageScaffold(
			navigationBar: CupertinoNavigationBar(
				middle: const Text('Ingredient Search'),
			),
			child: SafeArea(
				child: CustomScrollView(
					slivers: [
						SliverToBoxAdapter(
							child: Padding(
								padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
								child: CupertinoSearchTextField(
									onChanged: (value) {
										vm.search(value);
									},
								),
							),
						),

						SliverList(
							delegate: SliverChildBuilderDelegate(
								(context, index) {
									final ingredient = vm.ingredients[index];
									return IngredientSearchTileWidget(
										index: index,
										ingredient: ingredient,
									);
								},
								childCount: vm.ingredients.length,
							),
						),
					],
				),
			),
		);
	}
}