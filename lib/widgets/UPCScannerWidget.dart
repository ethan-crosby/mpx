import 'package:flutter/cupertino.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../config/api_config.dart';
import '../repositories/spoonacular_repository.dart';
import '../services/upc_service.dart';
import '../services/classify_service.dart';
import '../models/ingredient.dart';

class UPCSannerWidget extends StatefulWidget {
	UPCSannerWidget({super.key});

	@override
	State<UPCSannerWidget> createState() => _UPCSannerWidgetState();
}

class _UPCSannerWidgetState extends State<UPCSannerWidget> {
	Barcode? _barcode;
	bool _hasPopped = false;

	late final SpoonacularRepository repository;
	late final UPCService upcService;
	late final ClassifyService classifyService;

	@override
	void initState() {
		super.initState();
		repository = SpoonacularRepository(apiKey: ApiConfig.spoonacularApiKey);
		upcService = UPCService(repository);
	}

	Future<void> _handleBarcode(BarcodeCapture barcodes) async {
		if (mounted && !_hasPopped) {
			final barcode = barcodes.barcodes.firstOrNull;
			if (barcode != null) {
				_hasPopped = true;

				setState(() {
					_barcode = barcode;
				});

				try {
					final product = await upcService.getProductByUPC(barcode.rawValue ?? '');

					final Ingredient finalIngredient = await classifyService.classify(
						title: product.title,
					);

					Navigator.pop(context, finalIngredient);
					/*
					showCupertinoDialog(
						context: context,
						builder: (BuildContext context) {
							return CupertinoAlertDialog(
								title: Text('Error'),
								content: Text('Not an ingredient'),
								actions: [
									CupertinoDialogAction(
										isDefaultAction: true,
										child: Text('OK'),
										onPressed: () {
											Navigator.of(context).pop();
											_hasPopped = false;
										},
									),
								],
							);
						},
					);
					*/
				} catch (e) {
					print('Error: $e');
					_hasPopped = false;
				}
			}
		}
	}

	@override
	Widget build(BuildContext context) {
		return CupertinoPageScaffold(
			navigationBar: CupertinoNavigationBar(
				middle: Text('UPC Scanner'),
			),
			child: MobileScanner(onDetect: _handleBarcode),
		);
	}
}
