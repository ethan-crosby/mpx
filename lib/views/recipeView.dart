import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../viewModels/recipeVM.dart';
import '../widgets/recipeTileWidget.dart';

class RecipeView extends StatefulWidget {
	const RecipeView({
		super.key,
	});

	@override
	State<RecipeView> createState() => _RecipeView();
}

class _RecipeView extends State<RecipeView> with TickerProviderStateMixin{
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
										final recipe = vm.recipes[index];

										final itemController = AnimationController(
											duration: const Duration(milliseconds: 500),
											vsync: this,
										);

										final delay = (index * 10) / 100.0;
										final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
											CurvedAnimation(
												parent: itemController,
												curve: Interval(delay, 1.0, curve: Curves.easeOut),
											),
										);

										WidgetsBinding.instance.addPostFrameCallback((_) {
											itemController.forward();
										});

										return FadeTransition(
											opacity: animation,
											child: RecipeTileWidget(
												index: index,
												recipe: recipe,
											),
										);
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