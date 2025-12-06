import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../viewModels/ingredientVM.dart';
import '../viewModels/ingredientSearchVM.dart';
import '../widgets/ingredientTileWidget.dart';
import '../widgets/UPCScannerWidget.dart';
import './ingredientSearchView.dart';
import '../config/api_config.dart';
import '../repositories/spoonacular_repository.dart';
import '../services/ingredient_service.dart';

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
					CupertinoSliverNavigationBar(
						largeTitle: Text('Ingredients'),
						trailing: CupertinoButton(
							padding: EdgeInsets.zero,
							onPressed: () {
								showCupertinoModalPopup<void>(
									context: context,
									builder: (BuildContext context) => CupertinoActionSheet(
										title: const Text('Add ingredient'),
										actions: <CupertinoActionSheetAction>[
											CupertinoActionSheetAction(
												isDefaultAction: true,
												onPressed: () async {
													final vm = context.read<IngredientVM>();

													Navigator.pop(context);

													final ingredient = await Navigator.of(context).push(
														CupertinoPageRoute(
															builder: (_) => MultiProvider(
																providers: [
																	ChangeNotifierProvider<IngredientSearchVM>(
																		create: (context) => IngredientSearchVM(
																			context.read<IngredientService>(),
																		),
																	),
																],
																child: IngredientSearchView(),
															),
														),
													);

													vm.addIngredient(ingredient);
												},
												child: const Text('Search'),
											),
											CupertinoActionSheetAction(
												onPressed: () async {
													final vm = context.read<IngredientVM>();

													Navigator.pop(context);

													final ingredient = await Navigator.of(context).push(
														CupertinoPageRoute(
															builder: (_) => UPCSannerWidget(),
														),
													);

													vm.addIngredient(ingredient);
												},
												child: const Text('Scan UPC'),
											),
										],
									),
								);
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