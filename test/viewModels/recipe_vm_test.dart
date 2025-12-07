import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mpx/models/ingredient.dart';
import 'package:mpx/models/recipe.dart';
import 'package:mpx/services/recipe_service.dart';
import 'package:mpx/viewModels/recipeVM.dart';

import 'recipe_vm_test.mocks.dart';

@GenerateMocks([RecipeService])
void main() {
  late MockRecipeService mockService;

  setUp(() {
    mockService = MockRecipeService();
  });

  group('RecipeVM Tests', () {
    test('should initialize with loading state', () {
      // Ala Dr. Biehl's Testing UIs - Slide 5
      // Arrange
      final ingredients = [Ingredient(id: 1, name: 'Tomato')];

      when(
        mockService.getRecipesByIngredients(ingredients: any),
      ).thenAnswer((_) async => []);

      // Act
      final vm = RecipeVM(mockService, ingredients);

      // Assert
      expect(vm.loading, true);
    });

    test('should fetch recipes on init', () async {
      // Arrange
      final ingredients = [
        Ingredient(id: 1, name: 'Tomato'),
        Ingredient(id: 2, name: 'Pasta'),
      ];

      final mockRecipes = [
        Recipe(
          id: 1,
          title: 'Pasta with Tomato',
          usedIngredientCount: 2,
          missedIngredientCount: 0,
        ),
        Recipe(
          id: 2,
          title: 'Tomato Soup',
          usedIngredientCount: 1,
          missedIngredientCount: 1,
        ),
      ];

      when(
        mockService.getRecipesByIngredients(ingredients: ['Tomato', 'Pasta']),
      ).thenAnswer((_) async => mockRecipes);

      // Act
      final vm = RecipeVM(mockService, ingredients);
      await Future.delayed(Duration(milliseconds: 100));

      // Assert
      expect(vm.recipes.length, 2);
      expect(vm.recipes[0].title, 'Pasta with Tomato');
      expect(vm.recipes[1].title, 'Tomato Soup');
      expect(vm.loading, false);
      verify(
        mockService.getRecipesByIngredients(ingredients: ['Tomato', 'Pasta']),
      ).called(1);
    });

    test('should pass ingredient names to service', () async {
      // Arrange
      final ingredients = [
        Ingredient(id: 1, name: 'Tomato'),
        Ingredient(id: 2, name: 'Onion'),
        Ingredient(id: 3, name: 'Garlic'),
      ];

      when(
        mockService.getRecipesByIngredients(ingredients: any),
      ).thenAnswer((_) async => []);

      // Act
      RecipeVM(mockService, ingredients);
      await Future.delayed(Duration(milliseconds: 100));

      // Assert
      verify(
        mockService.getRecipesByIngredients(
          ingredients: ['Tomato', 'Onion', 'Garlic'],
        ),
      ).called(1);
    });

    test('should handle empty ingredient list', () async {
      // Arrange
      final ingredients = <Ingredient>[];

      when(
        mockService.getRecipesByIngredients(ingredients: []),
      ).thenAnswer((_) async => []);

      // Act
      final vm = RecipeVM(mockService, ingredients);
      await Future.delayed(Duration(milliseconds: 100));

      // Assert
      expect(vm.recipes, isEmpty);
      expect(vm.loading, false);
    });

    test('should handle empty recipe results', () async {
      // Arrange
      final ingredients = [Ingredient(id: 1, name: 'RareIngredient')];

      when(
        mockService.getRecipesByIngredients(ingredients: any),
      ).thenAnswer((_) async => []);

      // Act
      final vm = RecipeVM(mockService, ingredients);
      await Future.delayed(Duration(milliseconds: 100));

      // Assert
      expect(vm.recipes, isEmpty);
      expect(vm.loading, false);
    });

    test('should throw exception when service fails', () async {
      // Arrange
      final ingredients = [Ingredient(id: 1, name: 'Tomato')];

      when(
        mockService.getRecipesByIngredients(ingredients: any),
      ).thenThrow(Exception('API Error'));

      // Act & Assert
      expect(
        () => RecipeVM(mockService, ingredients),
        throwsA(isA<Exception>()),
      );
    });

    test('should set loading to false after successful fetch', () async {
      // Arrange
      final ingredients = [Ingredient(id: 1, name: 'Tomato')];

      when(
        mockService.getRecipesByIngredients(ingredients: any),
      ).thenAnswer((_) async => [Recipe(id: 1, title: 'Test Recipe')]);

      // Act
      final vm = RecipeVM(mockService, ingredients);
      expect(vm.loading, true);

      await Future.delayed(Duration(milliseconds: 100));

      // Assert
      expect(vm.loading, false);
    });

    test('should notify listeners during initialization', () async {
      // Arrange
      final ingredients = [Ingredient(id: 1, name: 'Tomato')];

      when(
        mockService.getRecipesByIngredients(ingredients: any),
      ).thenAnswer((_) async => []);

      int notifyCount = 0;

      // Act
      final vm = RecipeVM(mockService, ingredients);
      vm.addListener(() => notifyCount++);

      await Future.delayed(Duration(milliseconds: 100));

      // Assert
      expect(notifyCount, greaterThanOrEqualTo(1));
    });

    test('should handle single ingredient', () async {
      // Arrange
      final ingredients = [Ingredient(id: 1, name: 'Tomato')];

      final mockRecipes = [Recipe(id: 1, title: 'Tomato Salad')];

      when(
        mockService.getRecipesByIngredients(ingredients: ['Tomato']),
      ).thenAnswer((_) async => mockRecipes);

      // Act
      final vm = RecipeVM(mockService, ingredients);
      await Future.delayed(Duration(milliseconds: 100));

      // Assert
      expect(vm.recipes.length, 1);
      expect(vm.recipes[0].title, 'Tomato Salad');
    });

    test('should handle multiple recipes', () async {
      // Arrange
      final ingredients = [Ingredient(id: 1, name: 'Tomato')];

      final mockRecipes = List.generate(
        10,
        (i) => Recipe(id: i, title: 'Recipe $i'),
      );

      when(
        mockService.getRecipesByIngredients(ingredients: any),
      ).thenAnswer((_) async => mockRecipes);

      // Act
      final vm = RecipeVM(mockService, ingredients);
      await Future.delayed(Duration(milliseconds: 100));

      // Assert
      expect(vm.recipes.length, 10);
    });

    test('should properly dispose', () {
      // Arrange
      final ingredients = [Ingredient(id: 1, name: 'Tomato')];

      when(
        mockService.getRecipesByIngredients(ingredients: any),
      ).thenAnswer((_) async => []);

      // Act
      final vm = RecipeVM(mockService, ingredients);

      // Assert - Does not throw err
      expect(() => vm.dispose(), returnsNormally);
    });
  });
}
