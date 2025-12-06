import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

class _IngredientSearchView extends State<IngredientSearchView> with TickerProviderStateMixin {
	late final FocusNode _searchFocusNode;
	late final TextEditingController _controller;

	@override
	void initState() {
		super.initState();
		_searchFocusNode = FocusNode();
		_controller = TextEditingController();

		WidgetsBinding.instance.addPostFrameCallback((_) {
			_searchFocusNode.requestFocus();
		});
	}

	@override
	void dispose() {
		_searchFocusNode.dispose();
		_controller.dispose();
		super.dispose();
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
									controller: _controller,
									focusNode: _searchFocusNode,
									onChanged: (value) {
										vm.search(value);
									},
								),
							),
						),
						if (vm.loading)
							SliverToBoxAdapter(
								child: Center(child: CupertinoActivityIndicator()),
							)
						else
							SliverList(
								delegate: SliverChildBuilderDelegate(
									(context, index) {
										final ingredient = vm.ingredients[index];

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
											child: IngredientSearchTileWidget(
												index: index,
												ingredient: ingredient,
											),
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
