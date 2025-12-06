import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import '../viewModels/ingredientVM.dart';
import '../viewModels/ingredientSearchVM.dart';
import '../widgets/ingredientTileWidget.dart';
import '../widgets/UPCScannerWidget.dart';
import './ingredientSearchView.dart';
import '../config/api_config.dart';
import '../repositories/spoonacular_repository.dart';
import '../services/ingredient_service.dart';
import '../views/amountView.dart';
import '../models/ingredient.dart';

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
			child: Stack(
				children: [
					CustomScrollView(
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
															final navigator = Navigator.of(context);

															navigator.pop(context);

															final Ingredient? ingredient = await navigator.push(
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

															if (ingredient != null) {
																await navigator.push(
																	CupertinoPageRoute(
																		builder: (_) => AmountView(
																			ingredient: ingredient,
																		),
																	),
																);

																if(ingredient.amount != null) {																
																	vm.addIngredient(ingredient);
																}
															}
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
														child: const Text('Scan Barcode'),
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
											final ingredients = vm.ingredients;

											if (ingredients.isEmpty) {
												return Padding(
													padding: const EdgeInsets.all(16.0),
													child: Text(
														'Nothing here...',
														style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
																	fontSize: 20,
																	color: CupertinoColors.systemGrey,
																),
														textAlign: TextAlign.center,
													),
												);
											}
											final ingredient = ingredients[index];
											return IngredientTileWidget(
												index: index,
												ingredient: ingredient,
											);
										},
										childCount: context.watch<IngredientVM>().ingredients.isEmpty
												? 1
												: context.watch<IngredientVM>().ingredients.length,
									),
								),
							),
						],
					),
					Positioned(
						bottom: 30,
						right: 30,
						child: LiquidGlassLayer(
							settings: LiquidGlassSettings(
								thickness: 20,
								saturation: 1.5,
								glassColor: CupertinoColors.inactiveGray.resolveFrom(context),
								ambientStrength: 1.5,
							),
							child: LiquidGlass(
								shape: LiquidRoundedSuperellipse(
									borderRadius: 50,
								),
								child: Container(
									child: Center(
										child: Padding(
											padding: EdgeInsets.all(16),
											child: Text('Search Recipes'),
										),
									),
								),
							),
						),
					),
				],
			),
		);
	}
}