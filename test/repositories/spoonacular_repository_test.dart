import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mpx/repositories/spoonacular_repository.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'spoonacular_repository_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late MockClient mockClient;
  late SpoonacularRepository repository;
  late String testApiKey;

  setUp(() {
    testApiKey = dotenv.env['SPOONACULAR_API_KEY'] ?? '';
    mockClient = MockClient();
    repository = SpoonacularRepository(apiKey: testApiKey, client: mockClient);
  });

  group('SpoonacularRepository Tests', () {
    group('getProductByUPC', () {
      test('should return product data when successful', () async {
        // Ala Dr. Biehl's Testing UIs - Slide 5
        // Arrange
        final mockResponse = {
          'id': 1,
          'title': 'Test Product',
          'image': 'test.jpg',
        };

        when(mockClient.get(any)).thenAnswer(
          (_) async => http.Response(json.encode(mockResponse), 200),
        );

        // Act
        final result = await repository.getProductByUPC('123456');

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['id'], 1);
        expect(result['title'], 'Test Product');
        verify(mockClient.get(any)).called(1);
      });

      test('should throw exception on 401 status code', () async {
        // Arrange
        when(
          mockClient.get(any),
        ).thenAnswer((_) async => http.Response('Unauthorized', 401));

        // Act & Assert
        expect(
          () => repository.getProductByUPC('123456'),
          throwsA(
            predicate(
              (e) => e is Exception && e.toString().contains('Invalid API key'),
            ),
          ),
        );
      });

      test('should throw exception on 402 status code', () async {
        // Arrange
        when(
          mockClient.get(any),
        ).thenAnswer((_) async => http.Response('Payment Required', 402));

        // Act & Assert
        expect(
          () => repository.getProductByUPC('123456'),
          throwsA(
            predicate(
              (e) =>
                  e is Exception && e.toString().contains('API quota exceeded'),
            ),
          ),
        );
      });

      test('should throw exception on 404 status code', () async {
        // Arrange
        when(
          mockClient.get(any),
        ).thenAnswer((_) async => http.Response('Not Found', 404));

        // Act & Assert
        expect(
          () => repository.getProductByUPC('123456'),
          throwsA(
            predicate(
              (e) =>
                  e is Exception && e.toString().contains('Resource not found'),
            ),
          ),
        );
      });

      test('should throw exception on other error status codes', () async {
        // Arrange
        when(
          mockClient.get(any),
        ).thenAnswer((_) async => http.Response('Server Error', 500));

        // Act & Assert
        expect(
          () => repository.getProductByUPC('123456'),
          throwsA(
            predicate(
              (e) =>
                  e is Exception &&
                  e.toString().contains('Failed to load data'),
            ),
          ),
        );
      });
    });

    group('searchIngredients', () {
      test('should return list of ingredients when successful', () async {
        // Arrange
        final mockResponse = [
          {'id': 1, 'name': 'Tomato'},
          {'id': 2, 'name': 'Tomato Sauce'},
        ];

        when(mockClient.get(any)).thenAnswer(
          (_) async => http.Response(json.encode(mockResponse), 200),
        );

        // Act
        final result = await repository.searchIngredients(
          query: 'tomato',
          number: 10,
        );

        // Assert
        expect(result, isA<List<dynamic>>());
        expect(result.length, 2);
        expect(result[0]['name'], 'Tomato');
      });

      test('should return empty list when no results', () async {
        // Arrange
        when(
          mockClient.get(any),
        ).thenAnswer((_) async => http.Response(json.encode([]), 200));

        // Act
        final result = await repository.searchIngredients(
          query: 'xyz',
          number: 10,
        );

        // Assert
        expect(result, isEmpty);
      });

      test('should include query parameters in request', () async {
        // Arrange
        when(
          mockClient.get(any),
        ).thenAnswer((_) async => http.Response(json.encode([]), 200));

        // Act
        await repository.searchIngredients(query: 'tomato', number: 5);

        // Assert
        final captured = verify(mockClient.get(captureAny)).captured;
        final uri = captured.first as Uri;
        expect(uri.queryParameters['query'], 'tomato');
        expect(uri.queryParameters['number'], '5');
        expect(uri.queryParameters['metaInformation'], 'true');
        expect(uri.queryParameters['apiKey'], testApiKey);
      });

      test('should throw exception on error status code', () async {
        // Arrange
        when(
          mockClient.get(any),
        ).thenAnswer((_) async => http.Response('Error', 500));

        // Act & Assert
        expect(
          () => repository.searchIngredients(query: 'test', number: 10),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getRecipesByIngredients', () {
      test('should return list of recipes when successful', () async {
        // Arrange
        final mockResponse = [
          {'id': 1, 'title': 'Recipe 1'},
          {'id': 2, 'title': 'Recipe 2'},
        ];

        when(mockClient.get(any)).thenAnswer(
          (_) async => http.Response(json.encode(mockResponse), 200),
        );

        // Act
        final result = await repository.getRecipesByIngredients(
          ingredients: 'tomato,pasta',
          number: 10,
          ranking: 1,
        );

        // Assert
        expect(result, isA<List<dynamic>>());
        expect(result.length, 2);
      });

      test('should include query parameters in request', () async {
        // Arrange
        when(
          mockClient.get(any),
        ).thenAnswer((_) async => http.Response(json.encode([]), 200));

        // Act
        await repository.getRecipesByIngredients(
          ingredients: 'tomato,pasta',
          number: 5,
          ranking: 2,
        );

        // Assert
        final captured = verify(mockClient.get(captureAny)).captured;
        final uri = captured.first as Uri;
        expect(uri.queryParameters['ingredients'], 'tomato,pasta');
        expect(uri.queryParameters['number'], '5');
        expect(uri.queryParameters['ranking'], '2');
        expect(uri.queryParameters['apiKey'], testApiKey);
      });
    });

    group('getRecipeInformation', () {
      test('should return recipe details when successful', () async {
        // Arrange
        final mockResponse = {
          'id': 1,
          'title': 'Test Recipe',
          'image': 'recipe.jpg',
        };

        when(mockClient.get(any)).thenAnswer(
          (_) async => http.Response(json.encode(mockResponse), 200),
        );

        // Act
        final result = await repository.getRecipeInformation(1);

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['id'], 1);
        expect(result['title'], 'Test Recipe');
      });

      test('should include recipe ID in URL', () async {
        // Arrange
        when(
          mockClient.get(any),
        ).thenAnswer((_) async => http.Response(json.encode({}), 200));

        // Act
        await repository.getRecipeInformation(123);

        // Assert
        final captured = verify(mockClient.get(captureAny)).captured;
        final uri = captured.first as Uri;
        expect(uri.path, contains('/recipes/123/information'));
      });
    });

    group('getIngredientInformation', () {
      test('should return ingredient details when successful', () async {
        // Arrange
        final mockResponse = {'id': 1, 'name': 'Tomato', 'nutrition': {}};

        when(mockClient.get(any)).thenAnswer(
          (_) async => http.Response(json.encode(mockResponse), 200),
        );

        // Act
        final result = await repository.getIngredientInformation(
          id: 1,
          amount: 2.5,
          unit: 'cups',
        );

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['id'], 1);
      });

      test('should include query parameters in request', () async {
        // Arrange
        when(
          mockClient.get(any),
        ).thenAnswer((_) async => http.Response(json.encode({}), 200));

        // Act
        await repository.getIngredientInformation(
          id: 1,
          amount: 2.5,
          unit: 'cups',
        );

        // Assert
        final captured = verify(mockClient.get(captureAny)).captured;
        final uri = captured.first as Uri;
        expect(uri.queryParameters['amount'], '2.5');
        expect(uri.queryParameters['unit'], 'cups');
        expect(uri.path, contains('/food/ingredients/1/information'));
      });
    });

    group('classifyProductCategory', () {
      test('should return category string when successful', () async {
        // Arrange
        final mockResponse = {'category': 'Condiment', 'confidence': 0.95};

        when(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer(
          (_) async => http.Response(json.encode(mockResponse), 200),
        );

        // Act
        final result = await repository.classifyProductCategory(
          title: 'Tomato Sauce',
        );

        // Assert
        expect(result, isA<String>());
        expect(result, 'Condiment');
      });

      test('should return null when response is empty', () async {
        // Arrange
        when(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response(json.encode({}), 200));

        // Act
        final result = await repository.classifyProductCategory(
          title: 'Test Product',
        );

        // Assert
        expect(result, isNull);
      });

      test('should throw exception on error', () async {
        // Arrange
        when(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('Error', 500));

        // Act & Assert
        expect(
          () => repository.classifyProductCategory(title: 'Test'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Error Handling', () {
      test('should handle network errors', () async {
        // Arrange
        when(mockClient.get(any)).thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => repository.getProductByUPC('123'),
          throwsA(
            predicate(
              (e) => e is Exception && e.toString().contains('Network error'),
            ),
          ),
        );
      });

      test('should include API key in all requests', () async {
        // Arrange
        when(
          mockClient.get(any),
        ).thenAnswer((_) async => http.Response(json.encode([]), 200));

        // Act
        await repository.searchIngredients(query: 'test', number: 10);

        // Assert
        final captured = verify(mockClient.get(captureAny)).captured;
        final uri = captured.first as Uri;
        expect(uri.queryParameters['apiKey'], testApiKey);
      });
    });
  });
}
