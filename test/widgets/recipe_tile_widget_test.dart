import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx/models/recipe.dart';
import 'package:mpx/widgets/recipeTileWidget.dart';

void main() {
  Widget createTestWidget(Recipe recipe, {int index = 0}) {
    return CupertinoApp(
      home: CupertinoPageScaffold(
        child: RecipeTileWidget(index: index, recipe: recipe),
      ),
    );
  }

  group('RecipeTileWidget Tests', () {
    testWidgets('should display recipe title', (WidgetTester tester) async {
      // Ala Dr. Biehl's Testing UIs - Slide 5

      // Arrange
      final recipe = Recipe(id: 1, title: 'Pasta Carbonara', likes: 100);

      // Act
      await tester.pumpWidget(createTestWidget(recipe));

      // Assert
      expect(find.text('Pasta Carbonara'), findsOneWidget);
    });

    testWidgets('should display forward icon', (WidgetTester tester) async {
      // Arrange
      final recipe = Recipe(id: 1, title: 'Pasta Carbonara', likes: 100);

      // Act
      await tester.pumpWidget(createTestWidget(recipe));

      // Assert
      expect(find.byIcon(CupertinoIcons.forward), findsOneWidget);
    });

    testWidgets(
      'should have different background colors for even and odd indices',
      (WidgetTester tester) async {
        // Arrange
        final recipe = Recipe(id: 1, title: 'Test Recipe', likes: 50);

        // Act - Even index
        await tester.pumpWidget(createTestWidget(recipe, index: 0));
        await tester.pump();

        final evenContainer = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(RecipeTileWidget),
                matching: find.byType(Container),
              )
              .first,
        );

        // Act - Odd index
        await tester.pumpWidget(createTestWidget(recipe, index: 1));
        await tester.pump();

        final oddContainer = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(RecipeTileWidget),
                matching: find.byType(Container),
              )
              .first,
        );

        // Assert
        expect(evenContainer.color != oddContainer.color, true);
      },
    );

    testWidgets('should handle long recipe titles', (
      WidgetTester tester,
    ) async {
      // Arrange
      final recipe = Recipe(
        id: 1,
        title:
            'Super Delicious Extra Long Recipe Name That Should Be Truncated',
        likes: 250,
      );

      // Act
      await tester.pumpWidget(createTestWidget(recipe));

      // Assert
      expect(
        find.text(
          'Super Delicious Extra Long Recipe Name That Should Be Truncated',
        ),
        findsOneWidget,
      );
    });

    testWidgets('should be tappable', (WidgetTester tester) async {
      // Arrange
      final recipe = Recipe(id: 1, title: 'Pasta Carbonara', likes: 100);

      // Act
      await tester.pumpWidget(createTestWidget(recipe));

      // Assert
      expect(find.byType(CupertinoListTile), findsOneWidget);
    });

    testWidgets('should display recipe with special characters', (
      WidgetTester tester,
    ) async {
      // Arrange
      final recipe = Recipe(
        id: 1,
        title: 'Café au Lait & Crème Brûlée',
        likes: 150,
      );

      // Act
      await tester.pumpWidget(createTestWidget(recipe));

      // Assert
      expect(find.text('Café au Lait & Crème Brûlée'), findsOneWidget);
    });
  });
}
