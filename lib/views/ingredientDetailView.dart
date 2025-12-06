import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../viewModels/ingredientDetailVM.dart';
import '../widgets/ingredientSearchTileWidget.dart';
import '../models/ingredient.dart';
import '../models/nutrient.dart';
import '../views/amountView.dart';

class IngredientDetailView extends StatefulWidget {
	final Ingredient ingredient;

	const IngredientDetailView({super.key, required this.ingredient});

	@override
	_IngredientDetailViewState createState() => _IngredientDetailViewState();
}

class _IngredientDetailViewState extends State<IngredientDetailView> {
	late Ingredient ingredient;

	@override
	void initState() {
		super.initState();
		ingredient = widget.ingredient;
	}

	@override
	Widget build(BuildContext context) {
		final vm = context.watch<IngredientDetailVM>();

		return CupertinoPageScaffold(
			navigationBar: CupertinoNavigationBar(
				middle: Text(ingredient.name),
				trailing: CupertinoButton(
					onPressed: () async {
						final double? amount = ingredient.amount;
						final String? unit = ingredient.unit;

						await Navigator.of(context).push<Ingredient>(
							CupertinoPageRoute(
								builder: (_) => AmountView(
									ingredient: ingredient,
								),
							),
						);

						if (
							ingredient.amount != amount ||
							ingredient.unit != unit
						) {
							vm.refresh();
						}
					},
					padding: EdgeInsets.zero,
					child: Text('Edit'),
				),
			),
			child: SafeArea(
				child: Padding(
					padding: EdgeInsets.all(10),
					child: Container(
						padding: EdgeInsets.all(10),
						decoration: BoxDecoration(
							color: CupertinoColors.systemGrey6.resolveFrom(context),
							borderRadius: BorderRadius.circular(8),
						),
						width: double.infinity,
						child: vm.loading
							? Center(child: CupertinoActivityIndicator())
							: ListView(
								children: [
									Text(
										'Nutrition Facts',
										style: TextStyle(
											fontSize: 28,
											fontWeight: FontWeight.bold,
										),
									),
									SizedBox(height: 5),
									Row(
										mainAxisAlignment: MainAxisAlignment.spaceBetween,
										children: [
											Text('Amount'),
											Text(
												'${ingredient.amount ?? 0.0} ${ingredient.unit ?? 'g'}',
											),
										],
									),
									Container(
										color: CupertinoColors.label.resolveFrom(context),
										width: double.infinity,
										height: 6,
									),
									Padding(
										padding: EdgeInsets.symmetric(vertical: 3.0),
										child: Container(
											width: double.infinity,
											child: Text(
												'% Daily Value',
												textAlign: TextAlign.right,
											),
										),
									),
									Container(
										color: CupertinoColors.label.resolveFrom(context),
										width: double.infinity,
										height: 1,
									),
									...vm.nutrients.map((nutrient) => nutritionItem(nutrient)),
								],
							),
					),
				),
			),
		);
	}

	Widget nutritionItem(Nutrient nutrient) {
		return Column(
			children: [
				Padding(
					padding: EdgeInsets.symmetric(vertical: 3.0),
					child: Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						children: [
							Row(
								children: [
									Text(
										nutrient.name,
										style: TextStyle(fontWeight: FontWeight.bold),
										overflow: TextOverflow.ellipsis,
										maxLines: 1,
									),
									Text(
										' ${nutrient.amount}',
										overflow: TextOverflow.ellipsis,
										maxLines: 1,
									),
									Text(
										nutrient.unit,
										overflow: TextOverflow.ellipsis,
										maxLines: 1,
									),
								],
							),
							Text(
								'${nutrient.percentOfDailyNeeds}%',
								style: TextStyle(fontWeight: FontWeight.bold),
								overflow: TextOverflow.ellipsis,
								maxLines: 1,
							),
						],
					),
				),
				Container(
					color: CupertinoColors.label.resolveFrom(context),
					width: double.infinity,
					height: 1,
				),
			],
		);
	}
}
