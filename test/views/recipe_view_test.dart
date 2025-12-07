import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:mpx/models/recipe.dart';
import 'package:mpx/viewModels/recipeVM.dart';
import 'package:mpx/views/recipeView.dart';

import 'recipe_view_test.mocks.dart';

@GenerateMocks([RecipeVM])
void main() {
  late MockRecipeVM mockVM;

  setUp(() {
    mockVM = MockRecipeVM();
  });

  Widget createTestWidget() {
    return ChangeNotifierProvider<RecipeVM>.value(
      value: mockVM,
      child: CupertinoApp(home: RecipeView()),
    );
  }

  group('RecipeView Tests', () {
    testWidgets('should display navigation bar with title', (
      WidgetTester tester,
    ) async {
      // Ala Dr. Biehl's Testing UIs - Slide 5
      // Arrange
      when(mockVM.loading).thenReturn(false);
      when(mockVM.recipes).thenReturn([]);

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Recipe Search'), findsOneWidget);
      expect(find.byType(CupertinoNavigationBar), findsOneWidget);
    });

    testWidgets('should display loading indicator when loading', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockVM.loading).thenReturn(true);
      when(mockVM.recipes).thenReturn([]);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
    });

    testWidgets('should display recipes when not loading', (
      WidgetTester tester,
    ) async {
      // Arrange
      final recipes = [
        Recipe(id: 1, title: 'Pasta Carbonara', likes: 100),
        Recipe(id: 2, title: 'Tomato Soup', likes: 50),
      ];

      when(mockVM.loading).thenReturn(false);
      when(mockVM.recipes).thenReturn(recipes);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Pasta Carbonara'), findsOneWidget);
      expect(find.text('Tomato Soup'), findsOneWidget);
    });

    testWidgets('should display empty view when no recipes', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockVM.loading).thenReturn(false);
      when(mockVM.recipes).thenReturn([]);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert - nothing in list
      expect(find.byType(CupertinoActivityIndicator), findsNothing);
    });

    testWidgets('should display multiple recipes', (WidgetTester tester) async {
      // Arrange
      final recipes = List.generate(
        5,
        (i) => Recipe(id: i, title: 'Recipe $i', likes: i * 10),
      );

      when(mockVM.loading).thenReturn(false);
      when(mockVM.recipes).thenReturn(recipes);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      for (var i = 0; i < 5; i++) {
        expect(find.text('Recipe $i'), findsOneWidget);
      }
    });

    testWidgets('should use CustomScrollView for scrolling', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockVM.loading).thenReturn(false);
      when(mockVM.recipes).thenReturn([]);

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(CustomScrollView), findsOneWidget);
    });

    testWidgets('should display SafeArea', (WidgetTester tester) async {
      // Arrange
      when(mockVM.loading).thenReturn(false);
      when(mockVM.recipes).thenReturn([]);

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('should show loading then recipes', (
      WidgetTester tester,
    ) async {
      // Arrange - Initially loading
      when(mockVM.loading).thenReturn(true);
      when(mockVM.recipes).thenReturn([]);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert - Loading indicator should be visible
      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);

      // Arrange - Update to loaded state
      when(mockVM.loading).thenReturn(false);
      when(
        mockVM.recipes,
      ).thenReturn([Recipe(id: 1, title: 'Pasta', likes: 100)]);

      // Act - Rebuild widget
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert - Recipe should be visible
      expect(find.byType(CupertinoActivityIndicator), findsNothing);
      expect(find.text('Pasta'), findsOneWidget);
    });

    testWidgets('should handle large number of recipes', (
      WidgetTester tester,
    ) async {
      // Arrange
      final recipes = List.generate(
        50,
        (i) => Recipe(id: i, title: 'Recipe $i', likes: i),
      );

      when(mockVM.loading).thenReturn(false);
      when(mockVM.recipes).thenReturn(recipes);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(CustomScrollView), findsOneWidget);
      expect(find.text('Recipe 0'), findsOneWidget);
    });
  });
}
