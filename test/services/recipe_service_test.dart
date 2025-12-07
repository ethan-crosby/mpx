import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mpx/models/recipe.dart';
import 'package:mpx/repositories/spoonacular_repository.dart';
import 'package:mpx/services/recipe_service.dart';

import 'recipe_service_test.mocks.dart';

@GenerateMocks([SpoonacularRepository])
void main() {
  late MockSpoonacularRepository mockRepository;
  late RecipeService service;

  setUp(() {
    mockRepository = MockSpoonacularRepository();
    service = RecipeService(mockRepository);
  });

  group('RecipeService Tests', () {
    group('getRecipesByIngredients', () {
      test('should return list of recipes when successful', () async {
        // Ala Dr. Biehl's Testing UIs - Slide 5
        // Arrange
        final mockResponse = [
          {
            'id': 1,
            'title': 'Pasta Carbonara',
            'image': 'pasta.jpg',
            'usedIngredientCount': 3,
            'missedIngredientCount': 1,
          },
          {
            'id': 2,
            'title': 'Tomato Soup',
            'image': 'soup.jpg',
            'usedIngredientCount': 2,
            'missedIngredientCount': 2,
          },
        ];

        when(
          mockRepository.getRecipesByIngredients(
            ingredients: 'tomato,pasta',
            number: 10,
            ranking: 1,
          ),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await service.getRecipesByIngredients(
          ingredients: ['tomato', 'pasta'],
          number: 10,
          ranking: 1,
        );

        // Assert
        expect(result, isA<List<Recipe>>());
        expect(result.length, 2);
        expect(result[0].title, 'Pasta Carbonara');
        expect(result[1].title, 'Tomato Soup');
      });

      test('should join ingredients with comma', () async {
        // Arrange
        when(
          mockRepository.getRecipesByIngredients(
            ingredients: 'tomato,onion,garlic',
            number: any,
            ranking: any,
          ),
        ).thenAnswer((_) async => []);

        // Act
        await service.getRecipesByIngredients(
          ingredients: ['tomato', 'onion', 'garlic'],
        );

        // Assert
        verify(
          mockRepository.getRecipesByIngredients(
            ingredients: 'tomato,onion,garlic',
            number: 10,
            ranking: 1,
          ),
        ).called(1);
      });

      test('should use default parameters when not provided', () async {
        // Arrange
        when(
          mockRepository.getRecipesByIngredients(
            ingredients: anyNamed('ingredients'),
            number: 10,
            ranking: 1,
          ),
        ).thenAnswer((_) async => []);

        // Act
        await service.getRecipesByIngredients(ingredients: ['tomato']);

        // Assert
        verify(
          mockRepository.getRecipesByIngredients(
            ingredients: 'tomato',
            number: 10,
            ranking: 1,
          ),
        ).called(1);
      });

      test('should return empty list when no recipes found', () async {
        // Arrange
        when(
          mockRepository.getRecipesByIngredients(
            ingredients: anyNamed('ingredients'),
            number: anyNamed('number'),
            ranking: anyNamed('ranking'),
          ),
        ).thenAnswer((_) async => []);

        // Act
        final result = await service.getRecipesByIngredients(
          ingredients: ['xyz'],
        );

        // Assert
        expect(result, isEmpty);
      });

      test('should throw exception when repository fails', () async {
        // Arrange
        when(
          mockRepository.getRecipesByIngredients(
            ingredients: anyNamed('ingredients'),
            number: anyNamed('number'),
            ranking: anyNamed('ranking'),
          ),
        ).thenThrow(Exception('API Error'));

        // Act & Assert
        expect(
          () => service.getRecipesByIngredients(ingredients: ['tomato']),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle single ingredient', () async {
        // Arrange
        when(
          mockRepository.getRecipesByIngredients(
            ingredients: 'tomato',
            number: anyNamed('number'),
            ranking: anyNamed('ranking'),
          ),
        ).thenAnswer((_) async => []);

        // Act
        await service.getRecipesByIngredients(ingredients: ['tomato']);

        // Assert
        verify(
          mockRepository.getRecipesByIngredients(
            ingredients: 'tomato',
            number: anyNamed('number'),
            ranking: anyNamed('ranking'),
          ),
        ).called(1);
      });
    });

    group('getRecipeDetails', () {
      test('should return recipe details when successful', () async {
        // Arrange
        final mockResponse = {
          'id': 1,
          'title': 'Pasta Carbonara',
          'image': 'pasta.jpg',
          'likes': 100,
        };

        when(
          mockRepository.getRecipeInformation(1),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await service.getRecipeDetails(1);

        // Assert
        expect(result, isA<Recipe>());
        expect(result.id, 1);
        expect(result.title, 'Pasta Carbonara');
        verify(mockRepository.getRecipeInformation(1)).called(1);
      });

      test('should throw exception when repository fails', () async {
        // Arrange
        when(
          mockRepository.getRecipeInformation(1),
        ).thenThrow(Exception('API Error'));

        // Act & Assert
        expect(() => service.getRecipeDetails(1), throwsA(isA<Exception>()));
      });
    });

    group('sortBySimilarity', () {
      test('should sort recipes by used ingredient count descending', () {
        // Arrange
        final recipes = [
          Recipe(
            id: 1,
            title: 'Recipe 1',
            usedIngredientCount: 2,
            missedIngredientCount: 1,
          ),
          Recipe(
            id: 2,
            title: 'Recipe 2',
            usedIngredientCount: 5,
            missedIngredientCount: 1,
          ),
          Recipe(
            id: 3,
            title: 'Recipe 3',
            usedIngredientCount: 3,
            missedIngredientCount: 1,
          ),
        ];

        // Act
        final result = service.sortBySimilarity(recipes);

        // Assert
        expect(result[0].id, 2); // 5 used ingredients
        expect(result[1].id, 3); // 3 used ingredients
        expect(result[2].id, 1); // 2 used ingredients
      });

      test(
        'should sort by missed ingredient count when used counts are equal',
        () {
          // Arrange
          final recipes = [
            Recipe(
              id: 1,
              title: 'Recipe 1',
              usedIngredientCount: 3,
              missedIngredientCount: 5,
            ),
            Recipe(
              id: 2,
              title: 'Recipe 2',
              usedIngredientCount: 3,
              missedIngredientCount: 2,
            ),
            Recipe(
              id: 3,
              title: 'Recipe 3',
              usedIngredientCount: 3,
              missedIngredientCount: 3,
            ),
          ];

          // Act
          final result = service.sortBySimilarity(recipes);

          // Assert
          expect(result[0].id, 2); // 2 missed
          expect(result[1].id, 3); // 3 missed
          expect(result[2].id, 1); // 5 missed
        },
      );

      test('should handle null ingredient counts as 0', () {
        // Arrange
        final recipes = [
          Recipe(id: 1, title: 'Recipe 1', usedIngredientCount: 2),
          Recipe(id: 2, title: 'Recipe 2'),
          Recipe(id: 3, title: 'Recipe 3', usedIngredientCount: 1),
        ];

        // Act
        final result = service.sortBySimilarity(recipes);

        // Assert
        expect(result[0].id, 1); // 2 used
        expect(result[1].id, 3); // 1 used
        expect(result[2].id, 2); // 0 used (null)
      });

      test('should return new list without modifying original', () {
        // Arrange
        final recipes = [
          Recipe(id: 1, title: 'Recipe 1', usedIngredientCount: 1),
          Recipe(id: 2, title: 'Recipe 2', usedIngredientCount: 3),
        ];
        final originalOrder = recipes.map((r) => r.id).toList();

        // Act
        final result = service.sortBySimilarity(recipes);

        // Assert
        expect(recipes.map((r) => r.id).toList(), originalOrder);
        expect(result.map((r) => r.id).toList(), [2, 1]);
      });

      test('should handle empty list', () {
        // Arrange
        final recipes = <Recipe>[];

        // Act
        final result = service.sortBySimilarity(recipes);

        // Assert
        expect(result, isEmpty);
      });

      test('should handle single recipe', () {
        // Arrange
        final recipes = [
          Recipe(id: 1, title: 'Recipe 1', usedIngredientCount: 5),
        ];

        // Act
        final result = service.sortBySimilarity(recipes);

        // Assert
        expect(result.length, 1);
        expect(result[0].id, 1);
      });
    });
  });
}
