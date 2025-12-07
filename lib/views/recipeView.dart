import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
// import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
// import 'package:flutter_svg/flutter_svg.dart';

import '../viewModels/recipeVM.dart';

/*
import '../viewModels/ingredientSearchVM.dart';
import '../widgets/ingredientTileWidget.dart';
import '../widgets/UPCScannerWidget.dart';
import './ingredientSearchView.dart';
import '../config/api_config.dart';
import '../repositories/spoonacular_repository.dart';
import '../services/ingredient_service.dart';
import '../views/amountView.dart';
import '../models/ingredient.dart';
*/

class RecipeView extends StatefulWidget {
	const RecipeView({
		super.key,
	});

	@override
	State<RecipeView> createState() => _RecipeView();
}

class _RecipeView extends State<RecipeView> {
	@override
	void initState() {
		super.initState();
	}

	@override
	Widget build(BuildContext context) {
		final vm = context.watch<RecipeVM>();

		return CupertinoPageScaffold(
			navigationBar: CupertinoNavigationBar(
				middle: const Text('Recipe Search'),
			),
			child: SafeArea(
				child: CustomScrollView(
					slivers: [
						if (vm.loading)
							SliverToBoxAdapter(
								child: Center(child: CupertinoActivityIndicator()),
							)
						else
							SliverList(
								delegate: SliverChildBuilderDelegate(
									(context, index) {

									},
									childCount: vm.recipes.length,
								),
							),
					],
				),
			),
		);
	}
}