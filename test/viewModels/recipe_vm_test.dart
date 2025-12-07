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
  });
}
