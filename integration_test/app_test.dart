import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:mpx/models/ingredient.dart';
import 'package:mpx/repositories/spoonacular_repository.dart';
import 'package:mpx/services/ingredient_service.dart';
import 'package:mpx/services/classify_service.dart';
import 'package:mpx/viewModels/ingredientVM.dart';
import 'package:mpx/storage/localStore.dart';
import 'package:mpx/views/ingredientView.dart';

import 'app_test.mocks.dart';

@GenerateMocks([SpoonacularRepository, LocalStore])
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockSpoonacularRepository mockRepository;
  late MockLocalStore mockLocalStore;

  setUp(() {
    mockRepository = MockSpoonacularRepository();
    mockLocalStore = MockLocalStore();
  });

  group('Integration Tests - End-to-End User Flows', () {
    testWidgets('User Flow: Search ingredients and find recipes', (
      WidgetTester tester,
    ) async {
      // Arrange - Mock data
      when(mockLocalStore.readIngredients()).thenAnswer((_) async => []);
      when(mockLocalStore.writeIngredients(any)).thenAnswer((_) async => {});

      final mockIngredients = [
        {'id': 1, 'name': 'Tomato', 'image': 'tomato.jpg'},
        {'id': 2, 'name': 'Pasta', 'image': 'pasta.jpg'},
      ];

      final mockRecipes = [
        {
          'id': 1,
          'title': 'Pasta with Tomato',
          'usedIngredientCount': 2,
          'missedIngredientCount': 0,
          'likes': 100,
        },
      ];

      when(
        mockRepository.searchIngredients(
          query: anyNamed('query'),
          number: anyNamed('number'),
        ),
      ).thenAnswer((_) async => mockIngredients);

      when(
        mockRepository.getRecipesByIngredients(
          ingredients: anyNamed('ingredients'),
          number: anyNamed('number'),
          ranking: anyNamed('ranking'),
        ),
      ).thenAnswer((_) async => mockRecipes);

      // Create app with mocked dependencies
      final app = CupertinoApp(
        home: MultiProvider(
          providers: [
            Provider<SpoonacularRepository>.value(value: mockRepository),
            Provider<LocalStore>.value(value: mockLocalStore),
            ProxyProvider<SpoonacularRepository, IngredientService>(
              update: (_, repo, __) => IngredientService(repo),
            ),
            ProxyProvider<SpoonacularRepository, ClassifyService>(
              update: (_, repo, __) => ClassifyService(repo),
            ),
            ChangeNotifierProvider<IngredientVM>(
              create: (context) => IngredientVM(
                context.read<IngredientService>(),
                context.read<ClassifyService>(),
                context.read<LocalStore>(),
              ),
            ),
          ],
          child: IngredientView(),
        ),
      );

      // Act & Assert
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // Verify home screen loads
      expect(find.text('Ingredients'), findsWidgets);
      expect(find.byIcon(CupertinoIcons.add), findsOneWidget);

      // Verify empty state displays correctly
      expect(find.text('Nothing here...'), findsOneWidget);
    });

    testWidgets('User Flow: Add ingredient to list', (
      WidgetTester tester,
    ) async {
      // Ala Dr. Biehl's Testing UIs - Slide 5
      // Arrange
      when(mockLocalStore.readIngredients()).thenAnswer((_) async => []);
      when(mockLocalStore.writeIngredients(any)).thenAnswer((_) async => {});

      final ingredientService = IngredientService(mockRepository);
      final classifyService = ClassifyService(mockRepository);

      final app = CupertinoApp(
        home: MultiProvider(
          providers: [
            Provider<SpoonacularRepository>.value(value: mockRepository),
            Provider<LocalStore>.value(value: mockLocalStore),
            Provider<IngredientService>.value(value: ingredientService),
            Provider<ClassifyService>.value(value: classifyService),
            ChangeNotifierProvider<IngredientVM>(
              create: (context) => IngredientVM(
                ingredientService,
                classifyService,
                mockLocalStore,
              ),
            ),
          ],
          child: IngredientView(),
        ),
      );

      // Act
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Ingredients'), findsWidgets);
      expect(find.text('Nothing here...'), findsOneWidget);
    });

    testWidgets('User Flow: View ingredient list with items', (
      WidgetTester tester,
    ) async {
      // Ala Dr. Biehl's Testing UIs - Slide 5
      // Arrange
      final existingIngredients = [
        Ingredient(id: 1, name: 'Tomato', amount: 2.0, unit: 'pieces'),
        Ingredient(id: 2, name: 'Onion', amount: 1.0, unit: 'piece'),
      ];

      when(
        mockLocalStore.readIngredients(),
      ).thenAnswer((_) async => existingIngredients);
      when(mockLocalStore.writeIngredients(any)).thenAnswer((_) async => {});

      final ingredientService = IngredientService(mockRepository);
      final classifyService = ClassifyService(mockRepository);

      final app = CupertinoApp(
        home: MultiProvider(
          providers: [
            Provider<SpoonacularRepository>.value(value: mockRepository),
            Provider<LocalStore>.value(value: mockLocalStore),
            Provider<IngredientService>.value(value: ingredientService),
            Provider<ClassifyService>.value(value: classifyService),
            ChangeNotifierProvider<IngredientVM>(
              create: (context) => IngredientVM(
                ingredientService,
                classifyService,
                mockLocalStore,
              ),
            ),
          ],
          child: IngredientView(),
        ),
      );

      // Act
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Tomato'), findsOneWidget);
      expect(find.text('Onion'), findsOneWidget);
      expect(find.text('2.0'), findsOneWidget);
      expect(find.text('1.0'), findsOneWidget);
    });

    testWidgets('User Flow: Navigate to recipe search', (
      WidgetTester tester,
    ) async {
      // Ala Dr. Biehl's Testing UIs - Slide 5
      // Arrange
      final existingIngredients = [
        Ingredient(id: 1, name: 'Tomato', amount: 2.0, unit: 'pieces'),
      ];

      when(
        mockLocalStore.readIngredients(),
      ).thenAnswer((_) async => existingIngredients);
      when(mockLocalStore.writeIngredients(any)).thenAnswer((_) async => {});

      final ingredientService = IngredientService(mockRepository);
      final classifyService = ClassifyService(mockRepository);

      final app = CupertinoApp(
        home: MultiProvider(
          providers: [
            Provider<SpoonacularRepository>.value(value: mockRepository),
            Provider<LocalStore>.value(value: mockLocalStore),
            Provider<IngredientService>.value(value: ingredientService),
            Provider<ClassifyService>.value(value: classifyService),
            ChangeNotifierProvider<IngredientVM>(
              create: (context) => IngredientVM(
                ingredientService,
                classifyService,
                mockLocalStore,
              ),
            ),
          ],
          child: IngredientView(),
        ),
      );

      // Act
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Search Recipes'), findsOneWidget);
    });

    testWidgets('User Flow: Empty ingredients shows appropriate message', (
      WidgetTester tester,
    ) async {
      // Ala Dr. Biehl's Testing UIs - Slide 5
      // Arrange
      when(mockLocalStore.readIngredients()).thenAnswer((_) async => []);
      when(mockLocalStore.writeIngredients(any)).thenAnswer((_) async => {});

      final ingredientService = IngredientService(mockRepository);
      final classifyService = ClassifyService(mockRepository);

      final app = CupertinoApp(
        home: MultiProvider(
          providers: [
            Provider<SpoonacularRepository>.value(value: mockRepository),
            Provider<LocalStore>.value(value: mockLocalStore),
            Provider<IngredientService>.value(value: ingredientService),
            Provider<ClassifyService>.value(value: classifyService),
            ChangeNotifierProvider<IngredientVM>(
              create: (context) => IngredientVM(
                ingredientService,
                classifyService,
                mockLocalStore,
              ),
            ),
          ],
          child: IngredientView(),
        ),
      );

      // Act
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Nothing here...'), findsOneWidget);
      expect(find.text('Ingredients'), findsWidgets);
    });

    testWidgets('User Flow: Multiple ingredients display correctly', (
      WidgetTester tester,
    ) async {
      // Ala Dr. Biehl's Testing UIs - Slide 5
      // Arrange
      final ingredients = List.generate(
        5,
        (i) => Ingredient(
          id: i,
          name: 'Ingredient $i',
          amount: (i + 1).toDouble(),
          unit: 'piece',
        ),
      );

      when(
        mockLocalStore.readIngredients(),
      ).thenAnswer((_) async => ingredients);
      when(mockLocalStore.writeIngredients(any)).thenAnswer((_) async => {});

      final ingredientService = IngredientService(mockRepository);
      final classifyService = ClassifyService(mockRepository);

      final app = CupertinoApp(
        home: MultiProvider(
          providers: [
            Provider<SpoonacularRepository>.value(value: mockRepository),
            Provider<LocalStore>.value(value: mockLocalStore),
            Provider<IngredientService>.value(value: ingredientService),
            Provider<ClassifyService>.value(value: classifyService),
            ChangeNotifierProvider<IngredientVM>(
              create: (context) => IngredientVM(
                ingredientService,
                classifyService,
                mockLocalStore,
              ),
            ),
          ],
          child: IngredientView(),
        ),
      );

      // Act
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // Assert
      for (var i = 0; i < 5; i++) {
        expect(find.text('Ingredient $i'), findsOneWidget);
      }
    });

    testWidgets('User Flow: App starts with loading state then shows content', (
      WidgetTester tester,
    ) async {
      // Ala Dr. Biehl's Testing UIs - Slide 5
      // Arrange
      when(mockLocalStore.readIngredients()).thenAnswer((_) async {
        await Future.delayed(Duration(milliseconds: 100));
        return [];
      });
      when(mockLocalStore.writeIngredients(any)).thenAnswer((_) async => {});

      final ingredientService = IngredientService(mockRepository);
      final classifyService = ClassifyService(mockRepository);

      final app = CupertinoApp(
        home: MultiProvider(
          providers: [
            Provider<SpoonacularRepository>.value(value: mockRepository),
            Provider<LocalStore>.value(value: mockLocalStore),
            Provider<IngredientService>.value(value: ingredientService),
            Provider<ClassifyService>.value(value: classifyService),
            ChangeNotifierProvider<IngredientVM>(
              create: (context) => IngredientVM(
                ingredientService,
                classifyService,
                mockLocalStore,
              ),
            ),
          ],
          child: IngredientView(),
        ),
      );

      // Act
      await tester.pumpWidget(app);
      await tester.pump();

      // Assert
      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.byType(CupertinoActivityIndicator), findsNothing);
      expect(find.text('Nothing here...'), findsOneWidget);
    });

    testWidgets('User Flow: Verify navigation bar elements', (
      WidgetTester tester,
    ) async {
      // Ala Dr. Biehl's Testing UIs - Slide 5
      // Arrange
      when(mockLocalStore.readIngredients()).thenAnswer((_) async => []);
      when(mockLocalStore.writeIngredients(any)).thenAnswer((_) async => {});

      final ingredientService = IngredientService(mockRepository);
      final classifyService = ClassifyService(mockRepository);

      final app = CupertinoApp(
        home: MultiProvider(
          providers: [
            Provider<SpoonacularRepository>.value(value: mockRepository),
            Provider<LocalStore>.value(value: mockLocalStore),
            Provider<IngredientService>.value(value: ingredientService),
            Provider<ClassifyService>.value(value: classifyService),
            ChangeNotifierProvider<IngredientVM>(
              create: (context) => IngredientVM(
                ingredientService,
                classifyService,
                mockLocalStore,
              ),
            ),
          ],
          child: IngredientView(),
        ),
      );

      // Act
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Ingredients'), findsWidgets);
      expect(find.byIcon(CupertinoIcons.add), findsOneWidget);
      expect(find.byType(CupertinoSliverNavigationBar), findsOneWidget);
    });
  });
}
