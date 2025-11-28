import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
    return MaterialApp(
      title: 'MPX Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const TestPage(),
    );
  }
}

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final List<String> _results = [];
  bool _isLoading = false;

  void _addResult(String message) {
    setState(() {
      _results.add(message);
    });
  }

  Future<void> _testServices() async {
    setState(() {
      _results.clear();
      _isLoading = true;
    });

    final repository = SpoonacularRepository(
      apiKey: ApiConfig.spoonacularApiKey,
    );
    final ingredientService = IngredientService(repository);
    final recipeService = RecipeService(repository);
    final upcService = UPCService(repository);

    _addResult('Testing ingredient search...');
    try {
      final ingredients = await ingredientService.searchIngredients(
        query: 'tomato',
        number: 3,
      );
      _addResult('Found ${ingredients.length} ingredients:');
      for (final ingredient in ingredients) {
        _addResult('  • ${ingredient.name}');
      }
    } catch (e) {
      _addResult('Error: $e');
    }

    _addResult('\nTesting recipe search...');
    try {
      final recipes = await recipeService.getRecipesByIngredients(
        ingredients: ['tomato', 'chicken'],
        number: 3,
      );
      _addResult('Found ${recipes.length} recipes:');
      for (final recipe in recipes) {
        _addResult('  • ${recipe.title}');
      }
    } catch (e) {
      _addResult('Error: $e');
    }

    _addResult('\nTesting recipe sorting...');
    try {
      final recipes = await recipeService.getRecipesByIngredients(
        ingredients: ['tomato', 'onion'],
        number: 5,
      );
      final sorted = recipeService.sortBySimilarity(recipes);
      _addResult('Sorted ${sorted.length} recipes');
      if (sorted.isNotEmpty) {
        _addResult('Best match: ${sorted.first.title}');
      }
    } catch (e) {
      _addResult('Error: $e');
    }

    _addResult('\nTesting UPC lookup...');
    try {
      final product = await upcService.getProductByUPC('049000028911');
      _addResult('Product: ${product.title}');
      if (product.ingredients != null && product.ingredients!.isNotEmpty) {
        final ingredientNames = await upcService.getIngredientsFromUPC('049000028911');
        _addResult('Ingredients: ${ingredientNames.join(", ")}');
      } else {
        _addResult('No ingredients found');
      }
    } catch (e) {
      _addResult('Error: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _testServices,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Test API'),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _results.length,
              itemBuilder: (context, index) {
                return Text(
                  _results[index],
                  style: const TextStyle(fontFamily: 'monospace'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
