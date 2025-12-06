import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'views/ingredientView.dart';
import 'viewModels/ingredientVM.dart';

import 'config/api_config.dart';
import 'repositories/spoonacular_repository.dart';
import 'services/ingredient_service.dart';
import 'services/recipe_service.dart';
import 'services/upc_service.dart';

void main() async {
	await dotenv.load(fileName: '.env');
	runApp(const MyApp());
}

class MyApp extends StatelessWidget {
	const MyApp({super.key});

	@override
	Widget build(BuildContext context) {
		return MultiProvider(
			providers: [
				Provider<SpoonacularRepository>(
					create: (_) => SpoonacularRepository(
						apiKey: ApiConfig.spoonacularApiKey,
					),
				),

				ProxyProvider<SpoonacularRepository, IngredientService>(
					update: (_, repo, __) => IngredientService(repo),
				),

				ChangeNotifierProvider<IngredientVM>(
					create: (context) => IngredientVM(
						context.read<IngredientService>(),
					),
				),
			],
			child: CupertinoApp(
				title: 'Recipe Finder',
				theme: CupertinoThemeData(
					// This automatically adapts to light/dark if you use system colors
					primaryColor: CupertinoColors.activeBlue,
					scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground, 
					barBackgroundColor: CupertinoColors.systemGroupedBackground,
				),
				home: IngredientView(),
			),
		);
	}
}