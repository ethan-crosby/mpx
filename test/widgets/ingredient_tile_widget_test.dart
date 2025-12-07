import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:mpx/models/ingredient.dart';
import 'package:mpx/viewModels/ingredientVM.dart';
import 'package:mpx/widgets/ingredientTileWidget.dart';

import 'ingredient_tile_widget_test.mocks.dart';

@GenerateMocks([IngredientVM])
void main() {
  late MockIngredientVM mockVM;

  setUp(() {
    mockVM = MockIngredientVM();
  });

  Widget createTestWidget(Ingredient ingredient) {
    return CupertinoApp(
      home: ChangeNotifierProvider<IngredientVM>.value(
        value: mockVM,
        child: CupertinoPageScaffold(
          child: IngredientTileWidget(index: 0, ingredient: ingredient),
        ),
      ),
    );
  }

  group('IngredientTileWidget Tests', () {
    testWidgets('should display ingredient name', (WidgetTester tester) async {
      // Ala Dr. Biehl's Testing UIs - Slide 5
      // Arrange
      final ingredient = Ingredient(
        id: 1,
        name: 'Tomato',
        amount: 2.5,
        unit: 'cups',
      );

      // Act
      await tester.pumpWidget(createTestWidget(ingredient));

      // Assert
      expect(find.text('Tomato'), findsOneWidget);
    });

    testWidgets('should display ingredient amount and unit', (
      WidgetTester tester,
    ) async {
      // Ala Dr. Biehl's Testing UIs - Slide 5
      // Arrange
      final ingredient = Ingredient(
        id: 1,
        name: 'Tomato',
        amount: 2.5,
        unit: 'cups',
      );

      // Act
      await tester.pumpWidget(createTestWidget(ingredient));

      // Assert
      expect(find.text('2.5'), findsOneWidget);
      expect(find.text(' cups'), findsOneWidget);
    });

    testWidgets('should display default unit when not provided', (
      WidgetTester tester,
    ) async {
      // Ala Dr. Biehl's Testing UIs - Slide 5
      // Arrange
      final ingredient = Ingredient(id: 1, name: 'Tomato', amount: 2.5);

      // Act
      await tester.pumpWidget(createTestWidget(ingredient));

      // Assert
      expect(find.text(' g'), findsOneWidget);
    });

    testWidgets('should display 0.0 when amount is null', (
      WidgetTester tester,
    ) async {
      // Ala Dr. Biehl's Testing UIs - Slide 5
      // Arrange
      final ingredient = Ingredient(id: 1, name: 'Tomato');

      // Act
      await tester.pumpWidget(createTestWidget(ingredient));

      // Assert
      expect(find.text('0.0'), findsOneWidget);
    });

    testWidgets('should display forward icon', (WidgetTester tester) async {
      // Ala Dr. Biehl's Testing UIs - Slide 5
      // Arrange
      final ingredient = Ingredient(id: 1, name: 'Tomato');

      // Act
      await tester.pumpWidget(createTestWidget(ingredient));

      // Assert
      expect(find.byIcon(CupertinoIcons.forward), findsOneWidget);
    });

    testWidgets(
      'should have different background colors for even and odd indices',
      (WidgetTester tester) async {
        // Ala Dr. Biehl's Testing UIs - Slide 5
        // Arrange
        final ingredient = Ingredient(id: 1, name: 'Tomato');

        final evenWidget = CupertinoApp(
          home: ChangeNotifierProvider<IngredientVM>.value(
            value: mockVM,
            child: CupertinoPageScaffold(
              child: IngredientTileWidget(index: 0, ingredient: ingredient),
            ),
          ),
        );

        final oddWidget = CupertinoApp(
          home: ChangeNotifierProvider<IngredientVM>.value(
            value: mockVM,
            child: CupertinoPageScaffold(
              child: IngredientTileWidget(index: 1, ingredient: ingredient),
            ),
          ),
        );

        // Act
        await tester.pumpWidget(evenWidget);
        await tester.pump();

        // Even index
        final evenContainer = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(IngredientTileWidget),
                matching: find.byType(Container),
              )
              .first,
        );

        await tester.pumpWidget(oddWidget);
        await tester.pump();

        // Odd index
        final oddContainer = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(IngredientTileWidget),
                matching: find.byType(Container),
              )
              .first,
        );

        // Assert
        expect(evenContainer.color != oddContainer.color, true);
      },
    );

    testWidgets('should display ingredient with special characters', (
      WidgetTester tester,
    ) async {
      // Ala Dr. Biehl's Testing UIs - Slide 5
      // Arrange
      final ingredient = Ingredient(
        id: 1,
        name: 'Jalapeño Peppers',
        amount: 3.0,
        unit: 'pieces',
      );

      // Act
      await tester.pumpWidget(createTestWidget(ingredient));

      // Assert
      expect(find.text('Jalapeño Peppers'), findsOneWidget);
    });

    testWidgets('should display ingredient with long name', (
      WidgetTester tester,
    ) async {
      // Ala Dr. Biehl's Testing UIs - Slide 5
      // Arrange
      final ingredient = Ingredient(
        id: 1,
        name: 'Extra Virgin Cold Pressed Olive Oil from Mediterranean',
        amount: 2.0,
        unit: 'tablespoons',
      );

      // Act
      await tester.pumpWidget(createTestWidget(ingredient));

      // Assert
      expect(
        find.text('Extra Virgin Cold Pressed Olive Oil from Mediterranean'),
        findsOneWidget,
      );
    });

    testWidgets('should display fractional amounts correctly', (
      WidgetTester tester,
    ) async {
      // Ala Dr. Biehl's Testing UIs - Slide 5
      // Arrange
      final ingredient = Ingredient(
        id: 1,
        name: 'Tomato',
        amount: 0.5,
        unit: 'teaspoon',
      );

      // Act
      await tester.pumpWidget(createTestWidget(ingredient));

      // Assert
      expect(find.text('0.5'), findsOneWidget);
      expect(find.text(' teaspoon'), findsOneWidget);
    });
  });
}
