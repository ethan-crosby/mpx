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
				// 1. Repository (core dependency)
				Provider<SpoonacularRepository>(
					create: (_) => SpoonacularRepository(
						apiKey: ApiConfig.spoonacularApiKey,
					),
				),

				// 2. Services depending on the repository
				ProxyProvider<SpoonacularRepository, IngredientService>(
					update: (_, repo, __) => IngredientService(repo),
				),
				ProxyProvider<SpoonacularRepository, RecipeService>(
					update: (_, repo, __) => RecipeService(repo),
				),
				ProxyProvider<SpoonacularRepository, UPCService>(
					update: (_, repo, __) => UPCService(repo),
				),

				// 3. ViewModel (depends on 3 services)
				ChangeNotifierProvider<IngredientVM>(
					create: (context) => IngredientVM(
						context.read<IngredientService>(),
					),
				),
			],
			child: CupertinoApp(
				title: 'Recipe Finder',
				theme: CupertinoThemeData(
					primaryColor: CupertinoColors.systemBlue,
					scaffoldBackgroundColor: CupertinoColors.systemBackground,
				),
				home: IngredientView(),
			),
		);
	}
}