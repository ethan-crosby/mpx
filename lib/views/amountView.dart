import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../models/ingredient.dart';
import '../viewModels/ingredientVM.dart';

class AmountView extends StatefulWidget {
	final Ingredient ingredient;

	AmountView({
		super.key,
		required this.ingredient,
	});

	@override
	_AmountViewState createState() => _AmountViewState(
		ingredient: ingredient,
	);
}

class _AmountViewState extends State<AmountView> {
	final Ingredient ingredient;
	late String _selectedUnit;

	_AmountViewState({
		required this.ingredient,
	});

	@override
	void initState() {
		super.initState();
		_selectedUnit = ingredient.unit ?? 'g';
	}

	@override
	Widget build(BuildContext context) {
		final List<String> _units =
			ingredient.possibleUnits == [] ?
			['g'] :
			ingredient.possibleUnits!;
		final TextEditingController _amountController = TextEditingController(
			text: ingredient.amount?.toString() ?? '',
		);

		return CupertinoPageScaffold(
			navigationBar: CupertinoNavigationBar(
				leading: CupertinoButton(
					onPressed: () {
						Navigator.pop(context);
					},
					padding: EdgeInsets.zero,
					child: Text(
						'Cancel',
						style: TextStyle(
							color: CupertinoColors.destructiveRed,
						),
					),
				),
				middle: Text(ingredient.name),
				trailing: CupertinoButton(
					onPressed: () {
						String enteredText = _amountController.text;
						double? amount = double.tryParse(enteredText);

						if (amount != null && amount > 0.0) {
							ingredient.amount = amount;
							ingredient.unit = _selectedUnit;

							context.read<IngredientVM>().changeAmount();

							Navigator.pop(context);
						} else {
							showCupertinoDialog(
								context: context,
								builder: (BuildContext context) {
									return CupertinoAlertDialog(
										title: Text('Error'),
										content: Text('Please enter an amount'),
										actions: [
											CupertinoDialogAction(
												isDefaultAction: true,
												child: Text('OK'),
												onPressed: () {
													Navigator.of(context).pop();
												},
											),
										],
									);
								},
							);
						}
					},
					padding: EdgeInsets.zero,
					child: Text(
						'Done',
					),
				),
			),
			child: SafeArea(
				child: CupertinoFormSection.insetGrouped(
					header: Text('Quantity of ${ingredient.name}'),
					children: [
						CupertinoFormRow(
							padding: EdgeInsets.all(10),
							child: CupertinoTextField(
								controller: _amountController,
								keyboardType: TextInputType.numberWithOptions(decimal: true),
								placeholder: 'Quantity',
								padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
							),
						),
						CupertinoFormRow(
							prefix: Text('Unit'),
							child: CupertinoButton(
								padding: EdgeInsets.zero,
								onPressed: () {
									showCupertinoModalPopup(
										context: context,
										builder: (_) => Container(
											height: 250,
											color: CupertinoColors.systemBackground.resolveFrom(context),
											child: Column(
												children: [
													SizedBox(
														height: 40,
														child: Row(
															mainAxisAlignment: MainAxisAlignment.end,
															children: [
																CupertinoButton(
																	padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
																	onPressed: () => Navigator.pop(context),
																	child: Text('Done'),
																),
															],
														),
													),
													Expanded(
														child: CupertinoPicker(
															itemExtent: 32.0,
															scrollController: FixedExtentScrollController(
																initialItem: _units.indexOf(_selectedUnit),
															),
															onSelectedItemChanged: (int index) {
																setState(() {
																	_selectedUnit = _units[index];
																});
															},
															children: _units.map((u) => Center(child: Text(u))).toList(),
														),
													),
												],
											),
										),
									);
								},
								child: Text(
									_selectedUnit,
									style: TextStyle(color: CupertinoColors.activeBlue.resolveFrom(context)),
								),
							),
						),
					],
				),
			),
		);
	}
}
