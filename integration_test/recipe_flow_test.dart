import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:mpx/models/ingredient.dart';
import 'package:mpx/services/recipe_service.dart';
import 'package:mpx/viewModels/recipeVM.dart';
import 'package:mpx/views/recipeView.dart';
import 'package:mpx/repositories/spoonacular_repository.dart';

import 'recipe_flow_test.mocks.dart';

@GenerateMocks([SpoonacularRepository])
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockSpoonacularRepository mockRepository;

  setUp(() {
    mockRepository = MockSpoonacularRepository();
  });

  group('Integration Tests - Recipe Search Flow', () {
    testWidgets('Recipe Flow: Load recipes based on ingredients', (
      WidgetTester tester,
    ) async {
      // Ala Dr. Biehl's Testing UIs - Slide 5
      // Arrange
      final ingredients = [
        Ingredient(id: 1, name: 'Tomato'),
        Ingredient(id: 2, name: 'Pasta'),
      ];

      final mockRecipes = [
        {
          'id': 1,
          'title': 'Pasta Carbonara',
          'image': 'pasta.jpg',
          'usedIngredientCount': 2,
          'missedIngredientCount': 0,
          'likes': 150,
        },
        {
          'id': 2,
          'title': 'Tomato Soup',
          'image': 'soup.jpg',
          'usedIngredientCount': 1,
          'missedIngredientCount': 1,
          'likes': 75,
        },
      ];

      when(
        mockRepository.getRecipesByIngredients(
          ingredients: 'Tomato,Pasta',
          number: anyNamed('number'),
          ranking: anyNamed('ranking'),
        ),
      ).thenAnswer((_) async => mockRecipes);

      final recipeService = RecipeService(mockRepository);

      final app = CupertinoApp(
        home: MultiProvider(
          providers: [
            Provider<SpoonacularRepository>.value(value: mockRepository),
            ProxyProvider<SpoonacularRepository, RecipeService>(
              update: (_, repo, __) => RecipeService(repo),
            ),
            ChangeNotifierProvider<RecipeVM>(
              create: (context) => RecipeVM(recipeService, ingredients),
            ),
          ],
          child: RecipeView(),
        ),
      );

      // Act
      await tester.pumpWidget(app);
      await tester.pump(); // Start async operation
      await tester.pumpAndSettle(); // Wait for all animations

      // Assert
      expect(find.text('Recipe Search'), findsOneWidget);
      expect(find.text('Pasta Carbonara'), findsOneWidget);
      expect(find.text('Tomato Soup'), findsOneWidget);
    });

    testWidgets('Recipe Flow: Show loading indicator initially', (
      WidgetTester tester,
    ) async {
      // Ala Dr. Biehl's Testing UIs - Slide 5
      // Arrange
      final ingredients = [Ingredient(id: 1, name: 'Tomato')];

      when(
        mockRepository.getRecipesByIngredients(
          ingredients: anyNamed('ingredients'),
          number: anyNamed('number'),
          ranking: anyNamed('ranking'),
        ),
      ).thenAnswer((_) async {
        await Future.delayed(Duration(milliseconds: 500));
        return [];
      });

      final recipeService = RecipeService(mockRepository);

      final app = CupertinoApp(
        home: MultiProvider(
          providers: [
            Provider<SpoonacularRepository>.value(value: mockRepository),
            ProxyProvider<SpoonacularRepository, RecipeService>(
              update: (_, repo, __) => RecipeService(repo),
            ),
            ChangeNotifierProvider<RecipeVM>(
              create: (context) => RecipeVM(recipeService, ingredients),
            ),
          ],
          child: RecipeView(),
        ),
      );

      // Act
      await tester.pumpWidget(app);
      await tester.pump();

      // Assert
      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(CupertinoActivityIndicator), findsNothing);
    });

    testWidgets('Recipe Flow: Display no recipes when list is empty', (
      WidgetTester tester,
    ) async {
      // Ala Dr. Biehl's Testing UIs - Slide 5
      // Arrange
      final ingredients = [Ingredient(id: 1, name: 'RareIngredient')];

      when(
        mockRepository.getRecipesByIngredients(
          ingredients: anyNamed('ingredients'),
          number: anyNamed('number'),
          ranking: anyNamed('ranking'),
        ),
      ).thenAnswer((_) async => []);

      final recipeService = RecipeService(mockRepository);

      final app = CupertinoApp(
        home: MultiProvider(
          providers: [
            Provider<SpoonacularRepository>.value(value: mockRepository),
            ProxyProvider<SpoonacularRepository, RecipeService>(
              update: (_, repo, __) => RecipeService(repo),
            ),
            ChangeNotifierProvider<RecipeVM>(
              create: (context) => RecipeVM(recipeService, ingredients),
            ),
          ],
          child: RecipeView(),
        ),
      );

      // Act
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Recipe Search'), findsOneWidget);
      expect(find.byType(CupertinoActivityIndicator), findsNothing);
    });

    testWidgets('Recipe Flow: Single ingredient search', (
      WidgetTester tester,
    ) async {
      // Ala Dr. Biehl's Testing UIs - Slide 5
      // Arrange
      final ingredients = [Ingredient(id: 1, name: 'Tomato')];

      final mockRecipes = [
        {'id': 1, 'title': 'Tomato Salad', 'likes': 50},
      ];

      when(
        mockRepository.getRecipesByIngredients(
          ingredients: 'Tomato',
          number: anyNamed('number'),
          ranking: anyNamed('ranking'),
        ),
      ).thenAnswer((_) async => mockRecipes);

      final recipeService = RecipeService(mockRepository);

      final app = CupertinoApp(
        home: MultiProvider(
          providers: [
            Provider<SpoonacularRepository>.value(value: mockRepository),
            ProxyProvider<SpoonacularRepository, RecipeService>(
              update: (_, repo, __) => RecipeService(repo),
            ),
            ChangeNotifierProvider<RecipeVM>(
              create: (context) => RecipeVM(recipeService, ingredients),
            ),
          ],
          child: RecipeView(),
        ),
      );

      // Act
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Tomato Salad'), findsOneWidget);
    });

    testWidgets('Recipe Flow: Multiple ingredients search', (
      WidgetTester tester,
    ) async {
      // Ala Dr. Biehl's Testing UIs - Slide 5
      // Arrange
      final ingredients = [
        Ingredient(id: 1, name: 'Tomato'),
        Ingredient(id: 2, name: 'Pasta'),
        Ingredient(id: 3, name: 'Garlic'),
      ];

      final mockRecipes = [
        {
          'id': 1,
          'title': 'Pasta Pomodoro',
          'usedIngredientCount': 3,
          'missedIngredientCount': 0,
          'likes': 200,
        },
      ];

      when(
        mockRepository.getRecipesByIngredients(
          ingredients: 'Tomato,Pasta,Garlic',
          number: anyNamed('number'),
          ranking: anyNamed('ranking'),
        ),
      ).thenAnswer((_) async => mockRecipes);

      final recipeService = RecipeService(mockRepository);

      final app = CupertinoApp(
        home: MultiProvider(
          providers: [
            Provider<SpoonacularRepository>.value(value: mockRepository),
            ProxyProvider<SpoonacularRepository, RecipeService>(
              update: (_, repo, __) => RecipeService(repo),
            ),
            ChangeNotifierProvider<RecipeVM>(
              create: (context) => RecipeVM(recipeService, ingredients),
            ),
          ],
          child: RecipeView(),
        ),
      );

      // Act
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Pasta Pomodoro'), findsOneWidget);
    });

    testWidgets('Recipe Flow: Navigation bar is always visible', (
      WidgetTester tester,
    ) async {
      // Ala Dr. Biehl's Testing UIs - Slide 5
      // Arrange
      final ingredients = [Ingredient(id: 1, name: 'Tomato')];

      when(
        mockRepository.getRecipesByIngredients(
          ingredients: anyNamed('ingredients'),
          number: anyNamed('number'),
          ranking: anyNamed('ranking'),
        ),
      ).thenAnswer((_) async => []);

      final recipeService = RecipeService(mockRepository);

      final app = CupertinoApp(
        home: MultiProvider(
          providers: [
            Provider<SpoonacularRepository>.value(value: mockRepository),
            ProxyProvider<SpoonacularRepository, RecipeService>(
              update: (_, repo, __) => RecipeService(repo),
            ),
            ChangeNotifierProvider<RecipeVM>(
              create: (context) => RecipeVM(recipeService, ingredients),
            ),
          ],
          child: RecipeView(),
        ),
      );

      // Act
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Recipe Search'), findsOneWidget);
      expect(find.byType(CupertinoNavigationBar), findsOneWidget);
    });
  });
}
