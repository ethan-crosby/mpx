import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../viewModels/ingredientDetailVM.dart';
import '../widgets/ingredientSearchTileWidget.dart';
import '../models/ingredient.dart';
import '../models/nutrient.dart';

class IngredientDetailView extends StatelessWidget {
	final Ingredient ingredient;

	const IngredientDetailView({
		super.key,
		required this.ingredient,
	});

	@override
	Widget build(BuildContext context) {
		final vm = context.watch<IngredientDetailVM>();

		return CupertinoPageScaffold(
			navigationBar: CupertinoNavigationBar(
				middle: Text(ingredient.name),
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
						child: vm.loading ?
							Container(
								alignment: Alignment.center,
								child: CupertinoActivityIndicator(),
							) :
							ListView(
								children: [
									Text(
										'Nutrition Facts',
										style: TextStyle(
											fontSize: 28,
											fontWeight: FontWeight.bold,
										),
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
											child:Text(
												'% Daily Value',
												textAlign: TextAlign.right,
											)
										),
									),
									Container(
										color: CupertinoColors.label.resolveFrom(context),
										width: double.infinity,
										height: 1,
									),
									...List.generate(
										vm.nutrients.length,
										(index) => NutitionItem(
											context: context,
											nutrient: vm.nutrients[index],
										),
									),
								],
							)
					),
				),
			),
		);
	}

	Widget NutitionItem({
		required BuildContext context,
		required Nutrient nutrient
	}) {
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
										style: TextStyle(
											fontWeight: FontWeight.bold,
										),
									),
									Text(
										' ${nutrient.amount.toString()}',
									),
									Text(
										nutrient.unit
									),
								],
							),
							Text(
								'${nutrient.percentOfDailyNeeds}%',
								style: TextStyle(
									fontWeight: FontWeight.bold,
								)
							)
						],
					),
				),
				Container(
					color: CupertinoColors.label.resolveFrom(context),
					width: double.infinity,
					height: 1,
				)
			],
		);
	}
}