import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mpx/models/product.dart';
import 'package:mpx/repositories/spoonacular_repository.dart';
import 'package:mpx/services/upc_service.dart';

import 'upc_service_test.mocks.dart';

@GenerateMocks([SpoonacularRepository])
void main() {
  late MockSpoonacularRepository mockRepository;
  late UPCService service;

  setUp(() {
    mockRepository = MockSpoonacularRepository();
    service = UPCService(mockRepository);
  });

  group('UPCService Tests', () {
    group('getProductByUPC', () {
      test('should return product when successful', () async {
        // Ala Dr. Biehl's Testing UIs - Slide 5
        // Arrange
        final mockResponse = {
          'id': 1,
          'title': 'Organic Tomato Sauce',
          'image': 'sauce.jpg',
          'upc': '012345678901',
          'breadcrumbs': ['Food', 'Condiments'],
          'brand': 'OrganicBrand',
          'ingredients': [
            {'id': 1, 'name': 'Tomatoes'},
            {'id': 2, 'name': 'Salt'},
          ],
        };

        when(
          mockRepository.getProductByUPC('012345678901'),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await service.getProductByUPC('012345678901');

        // Assert
        expect(result, isA<Product>());
        expect(result.id, 1);
        expect(result.title, 'Organic Tomato Sauce');
        expect(result.upc, '012345678901');
        expect(result.ingredients?.length, 2);
      });

      test(
        'should handle product with no ingredients list but ingredientList string',
        () async {
          // Arrange
          final mockResponse = {
            'id': 1,
            'title': 'Product',
            'ingredientList': 'Tomatoes, Salt, Sugar',
          };

          when(
            mockRepository.getProductByUPC('123'),
          ).thenAnswer((_) async => mockResponse);

          // Act
          final result = await service.getProductByUPC('123');

          // Assert
          expect(result.ingredients?.length, 3);
          expect(result.ingredients?[0].name, 'Tomatoes');
          expect(result.ingredients?[1].name, 'Salt');
          expect(result.ingredients?[2].name, 'Sugar');
        },
      );

      test('should handle breadcrumbs as string', () async {
        // Arrange
        final mockResponse = {
          'id': 1,
          'title': 'Product',
          'breadcrumbs': 'Food',
        };

        when(
          mockRepository.getProductByUPC('123'),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await service.getProductByUPC('123');

        // Assert
        expect(result.breadcrumbs, ['Food']);
      });

      test('should handle breadcrumbs as list', () async {
        // Arrange
        final mockResponse = {
          'id': 1,
          'title': 'Product',
          'breadcrumbs': ['Food', 'Snacks'],
        };

        when(
          mockRepository.getProductByUPC('123'),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await service.getProductByUPC('123');

        // Assert
        expect(result.breadcrumbs, ['Food', 'Snacks']);
      });

      test('should handle id as string', () async {
        // Arrange
        final mockResponse = {'id': '123', 'title': 'Product'};

        when(
          mockRepository.getProductByUPC('123'),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await service.getProductByUPC('123');

        // Assert
        expect(result.id, 123);
      });

      test('should handle id as num', () async {
        // Arrange
        final mockResponse = {'id': 123.0, 'title': 'Product'};

        when(
          mockRepository.getProductByUPC('123'),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await service.getProductByUPC('123');

        // Assert
        expect(result.id, 123);
      });

      test(
        'should default to "Unknown Product" when title is missing',
        () async {
          // Arrange
          final mockResponse = {'id': 1};

          when(
            mockRepository.getProductByUPC('123'),
          ).thenAnswer((_) async => mockResponse);

          // Act
          final result = await service.getProductByUPC('123');

          // Assert
          expect(result.title, 'Unknown Product');
        },
      );

      test('should use provided upc when not in response', () async {
        // Arrange
        final mockResponse = {'id': 1, 'title': 'Product'};

        when(
          mockRepository.getProductByUPC('123'),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await service.getProductByUPC('123');

        // Assert
        expect(result.upc, '123');
      });

      test('should handle servings and price as maps', () async {
        // Arrange
        final mockResponse = {
          'id': 1,
          'title': 'Product',
          'servings': {'number': 4.0, 'size': 2.0},
          'price': {'value': 4.99, 'unit': 'USD'},
        };

        when(
          mockRepository.getProductByUPC('123'),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await service.getProductByUPC('123');

        // Assert
        expect(result.servings, isA<Map<String, dynamic>>());
        expect(result.price, isA<Map<String, dynamic>>());
      });

      test('should throw exception when repository fails', () async {
        // Arrange
        when(
          mockRepository.getProductByUPC('123'),
        ).thenThrow(Exception('API Error'));

        // Act & Assert
        expect(() => service.getProductByUPC('123'), throwsA(isA<Exception>()));
      });
    });

    group('getIngredientsFromUPC', () {
      test('should return list of ingredient names', () async {
        // Arrange
        final mockResponse = {
          'id': 1,
          'title': 'Product',
          'ingredients': [
            {'id': 1, 'name': 'Tomatoes'},
            {'id': 2, 'name': 'Salt'},
            {'id': 3, 'name': 'Sugar'},
          ],
        };

        when(
          mockRepository.getProductByUPC('123'),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await service.getIngredientsFromUPC('123');

        // Assert
        expect(result, ['Tomatoes', 'Salt', 'Sugar']);
      });

      test(
        'should return empty list when product has no ingredients',
        () async {
          // Arrange
          final mockResponse = {'id': 1, 'title': 'Product'};

          when(
            mockRepository.getProductByUPC('123'),
          ).thenAnswer((_) async => mockResponse);

          // Act
          final result = await service.getIngredientsFromUPC('123');

          // Assert
          expect(result, isEmpty);
        },
      );

      test('should return empty list when ingredients list is empty', () async {
        // Arrange
        final mockResponse = {'id': 1, 'title': 'Product', 'ingredients': []};

        when(
          mockRepository.getProductByUPC('123'),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await service.getIngredientsFromUPC('123');

        // Assert
        expect(result, isEmpty);
      });

      test('should filter out empty ingredient names', () async {
        // Arrange
        final mockResponse = {
          'id': 1,
          'title': 'Product',
          'ingredients': [
            {'id': 1, 'name': 'Tomatoes'},
            {'id': 2, 'name': ''},
            {'id': 3, 'name': 'Salt'},
          ],
        };

        when(
          mockRepository.getProductByUPC('123'),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await service.getIngredientsFromUPC('123');

        // Assert
        expect(result, ['Tomatoes', 'Salt']);
      });

      test('should handle ingredients from ingredientList string', () async {
        // Arrange
        final mockResponse = {
          'id': 1,
          'title': 'Product',
          'ingredientList': 'Tomatoes, Salt, Sugar',
        };

        when(
          mockRepository.getProductByUPC('123'),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await service.getIngredientsFromUPC('123');

        // Assert
        expect(result, ['Tomatoes', 'Salt', 'Sugar']);
      });
    });
  });
}
