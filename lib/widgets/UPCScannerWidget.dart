import 'package:flutter/cupertino.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Implementation of Mobile Scanner example with simple configuration
class UPCSannerWidget extends StatefulWidget {
	/// Constructor for simple Mobile Scanner example
	UPCSannerWidget({super.key});

	@override
	State<UPCSannerWidget> createState() => _UPCSannerWidgetState();
}

class _UPCSannerWidgetState extends State<UPCSannerWidget> {
	Barcode? _barcode;
	bool _hasPopped = false;

	void _handleBarcode(BarcodeCapture barcodes) {
		if (mounted && !_hasPopped) {
			final barcode = barcodes.barcodes.firstOrNull;
			if (barcode != null) {
				setState(() {
					_barcode = barcode;
				});

				_hasPopped = true; // prevent multiple pops
				Navigator.pop(context, barcode.rawValue); // pass barcode back if needed
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