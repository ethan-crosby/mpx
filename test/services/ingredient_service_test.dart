import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mpx/models/ingredient.dart';
import 'package:mpx/repositories/spoonacular_repository.dart';
import 'package:mpx/services/ingredient_service.dart';

import 'ingredient_service_test.mocks.dart';

@GenerateMocks([SpoonacularRepository])
void main() {
  late MockSpoonacularRepository mockRepository;
  late IngredientService service;

  setUp(() {
    mockRepository = MockSpoonacularRepository();
    service = IngredientService(mockRepository);
  });

  group('IngredientService Tests', () {
    group('searchIngredients', () {
      test('should return list of ingredients when successful', () async {
        // Ala Dr. Biehl's Testing UIs - Slide 5
        // Arrange
        final mockResponse = [
          {'id': 1, 'name': 'Tomato', 'image': 'tomato.jpg'},
          {'id': 2, 'name': 'Onion', 'image': 'onion.jpg'},
        ];

        when(
          mockRepository.searchIngredients(query: 'tom', number: 10),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await service.searchIngredients(
          query: 'tom',
          number: 10,
        );

        // Assert
        expect(result, isA<List<Ingredient>>());
        expect(result.length, 2);
        expect(result[0].name, 'Tomato');
        expect(result[1].name, 'Onion');
        verify(
          mockRepository.searchIngredients(query: 'tom', number: 10),
        ).called(1);
      });

      test('should use default number parameter when not provided', () async {
        // Arrange
        when(
          mockRepository.searchIngredients(query: 'tom', number: 10),
        ).thenAnswer((_) async => []);

        // Act
        await service.searchIngredients(query: 'tom');

        // Assert
        verify(
          mockRepository.searchIngredients(query: 'tom', number: 10),
        ).called(1);
      });

      test('should return empty list when no results found', () async {
        // Ala Dr. Biehl's Testing UIs - Slide 5
        // Arrange
        when(
          mockRepository.searchIngredients(query: 'xyz', number: 10),
        ).thenAnswer((_) async => []);

        // Act
        final result = await service.searchIngredients(query: 'xyz');

        // Assert
        expect(result, isEmpty);
      });

      test('should throw exception when repository fails', () async {
        // Ala Dr. Biehl's Testing UIs - Slide 5
        // Arrange
        when(
          mockRepository.searchIngredients(
            query: anyNamed('query'),
            number: anyNamed('number'),
          ),
        ).thenThrow(Exception('API Error'));

        // Act & Assert
        expect(
          () => service.searchIngredients(query: 'tom'),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle custom number parameter', () async {
        // Arrange
        final mockResponse = List.generate(
          5,
          (i) => {'id': i, 'name': 'Ingredient $i'},
        );

        when(
          mockRepository.searchIngredients(query: 'test', number: 5),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await service.searchIngredients(
          query: 'test',
          number: 5,
        );

        // Assert
        expect(result.length, 5);
        verify(
          mockRepository.searchIngredients(query: 'test', number: 5),
        ).called(1);
      });
    });

    group('getIngredientById', () {
      test('should return ingredient when found', () async {
        // Arrange
        final mockResponse = [
          {'id': 1, 'name': 'Tomato'},
          {'id': 2, 'name': 'Onion'},
          {'id': 3, 'name': 'Garlic'},
        ];

        when(
          mockRepository.searchIngredients(query: '', number: 100),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await service.getIngredientById(2);

        // Assert
        expect(result, isNotNull);
        expect(result?.id, 2);
        expect(result?.name, 'Onion');
      });

      test('should return null when ingredient not found', () async {
        // Arrange
        final mockResponse = [
          {'id': 1, 'name': 'Tomato'},
          {'id': 2, 'name': 'Onion'},
        ];

        when(
          mockRepository.searchIngredients(query: '', number: 100),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await service.getIngredientById(999);

        // Assert
        expect(result, isNull);
      });

      test('should return null when repository returns empty list', () async {
        // Arrange
        when(
          mockRepository.searchIngredients(query: '', number: 100),
        ).thenAnswer((_) async => []);

        // Act
        final result = await service.getIngredientById(1);

        // Assert
        expect(result, isNull);
      });

      test('should throw exception when repository fails', () async {
        // Arrange
        when(
          mockRepository.searchIngredients(
            query: anyNamed('query'),
            number: anyNamed('number'),
          ),
        ).thenThrow(Exception('API Error'));

        // Act & Assert
        expect(() => service.getIngredientById(1), throwsA(isA<Exception>()));
      });
    });
  });
}
