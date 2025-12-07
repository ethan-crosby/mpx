import 'package:flutter_test/flutter_test.dart';
import 'package:mpx/models/ingredient.dart';
import 'package:mpx/models/recipe.dart';

void main() {
  group('Recipe Model Tests', () {
    test('should create a Recipe from JSON', () {
      // Ala Dr. Biehl's Testing UIs - Slide 5
      // Arrange
      final json = {
        'id': 1,
        'title': 'Pasta Carbonara',
        'image': 'pasta.jpg',
        'usedIngredientCount': 3,
        'missedIngredientCount': 2,
        'likes': 100,
        'missedIngredients': [
          {'id': 1, 'name': 'Eggs', 'image': 'egg.jpg'},
          {'id': 2, 'name': 'Bacon', 'image': 'bacon.jpg'},
        ],
        'usedIngredients': [
          {'id': 3, 'name': 'Pasta', 'image': 'pasta.jpg'},
        ],
      };

      // Act
      final recipe = Recipe.fromJson(json);

      // Assert
      expect(recipe.id, 1);
      expect(recipe.title, 'Pasta Carbonara');
      expect(recipe.image, 'pasta.jpg');
      expect(recipe.usedIngredientCount, 3);
      expect(recipe.missedIngredientCount, 2);
      expect(recipe.likes, 100);
      expect(recipe.missedIngredients?.length, 2);
      expect(recipe.missedIngredients?[0].name, 'Eggs');
      expect(recipe.usedIngredients?.length, 1);
      expect(recipe.usedIngredients?[0].name, 'Pasta');
    });

    test('should create a Recipe from JSON with null values', () {
      // Arrange
      final json = {'id': 1, 'title': 'Pasta Carbonara'};

      // Act
      final recipe = Recipe.fromJson(json);

      // Assert
      expect(recipe.id, 1);
      expect(recipe.title, 'Pasta Carbonara');
      expect(recipe.image, null);
      expect(recipe.usedIngredientCount, null);
      expect(recipe.missedIngredientCount, null);
      expect(recipe.likes, null);
      expect(recipe.missedIngredients, null);
      expect(recipe.usedIngredients, null);
    });

    test('should convert Recipe to JSON', () {
      // Arrange
      final recipe = Recipe(
        id: 1,
        title: 'Pasta Carbonara',
        image: 'pasta.jpg',
        usedIngredientCount: 3,
        missedIngredientCount: 2,
        likes: 100,
        missedIngredients: [
          Ingredient(id: 1, name: 'Eggs'),
          Ingredient(id: 2, name: 'Bacon'),
        ],
        usedIngredients: [Ingredient(id: 3, name: 'Pasta')],
      );

      // Act
      final json = recipe.toJson();

      // Assert
      expect(json['id'], 1);
      expect(json['title'], 'Pasta Carbonara');
      expect(json['image'], 'pasta.jpg');
      expect(json['usedIngredientCount'], 3);
      expect(json['missedIngredientCount'], 2);
      expect(json['likes'], 100);
      expect(json['missedIngredients'], isA<List>());
      expect((json['missedIngredients'] as List).length, 2);
      expect(json['usedIngredients'], isA<List>());
      expect((json['usedIngredients'] as List).length, 1);
    });

    test('should handle empty ingredient lists in toJson', () {
      // Arrange
      final recipe = Recipe(id: 1, title: 'Simple Recipe');

      // Act
      final json = recipe.toJson();

      // Assert
      expect(json['missedIngredients'], isEmpty);
      expect(json['usedIngredients'], isEmpty);
    });

    test('should create Recipe with required fields only', () {
      // Arrange & Act
      final recipe = Recipe(id: 1, title: 'Simple Recipe');

      // Assert
      expect(recipe.id, 1);
      expect(recipe.title, 'Simple Recipe');
      expect(recipe.image, null);
      expect(recipe.usedIngredientCount, null);
      expect(recipe.missedIngredientCount, null);
      expect(recipe.likes, null);
    });

    test('should parse empty ingredient lists from JSON', () {
      // Arrange
      final json = {
        'id': 1,
        'title': 'Recipe',
        'missedIngredients': [],
        'usedIngredients': [],
      };

      // Act
      final recipe = Recipe.fromJson(json);

      // Assert
      expect(recipe.missedIngredients, isEmpty);
      expect(recipe.usedIngredients, isEmpty);
    });
  });
}
