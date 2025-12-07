import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mpx/models/ingredient.dart';
import 'package:mpx/storage/localStore.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalStore Tests', () {
    late LocalStore localStore;

    setUp(() {
      localStore = LocalStore();
    });

    tearDown(() async {
      // Clear shared preferences after each test
      SharedPreferences.setMockInitialValues({});
    });

    group('readIngredients', () {
      test('should return empty list when no data stored', () async {
        // Ala Dr. Biehl's Testing UIs - Slide 5
        // Arrange
        SharedPreferences.setMockInitialValues({});

        // Act
        final result = await localStore.readIngredients();

        // Assert
        expect(result, isEmpty);
      });

      test('should return stored ingredients', () async {
        // Arrange
        final ingredientsJson = '''
        [
          {"id": 1, "name": "Tomato", "image": "tomato.jpg"},
          {"id": 2, "name": "Onion", "image": "onion.jpg"}
        ]
        ''';

        SharedPreferences.setMockInitialValues({
          'ingredients': ingredientsJson,
        });

        // Act
        final result = await localStore.readIngredients();

        // Assert
        expect(result.length, 2);
        expect(result[0].id, 1);
        expect(result[0].name, 'Tomato');
        expect(result[1].id, 2);
        expect(result[1].name, 'Onion');
      });

      test('should deserialize ingredients with all properties', () async {
        // Arrange
        final ingredientsJson = '''
        [
          {
            "id": 1,
            "name": "Tomato",
            "image": "tomato.jpg",
            "amount": 2.5,
            "unit": "cups",
            "original": "2.5 cups tomato",
            "possibleUnits": ["cup", "tablespoon"]
          }
        ]
        ''';

        SharedPreferences.setMockInitialValues({
          'ingredients': ingredientsJson,
        });

        // Act
        final result = await localStore.readIngredients();

        // Assert
        expect(result.length, 1);
        expect(result[0].id, 1);
        expect(result[0].name, 'Tomato');
        expect(result[0].amount, 2.5);
        expect(result[0].unit, 'cups');
        expect(result[0].possibleUnits, ['cup', 'tablespoon']);
      });

      test('should handle malformed JSON gracefully', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({'ingredients': 'invalid json'});

        // Act & Assert
        expect(
          () => localStore.readIngredients(),
          throwsA(isA<FormatException>()),
        );
      });
    });

    group('writeIngredients', () {
      test('should save ingredients to storage', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});
        final ingredients = [
          Ingredient(id: 1, name: 'Tomato', image: 'tomato.jpg'),
          Ingredient(id: 2, name: 'Onion', image: 'onion.jpg'),
        ];

        // Act
        await localStore.writeIngredients(ingredients);

        // Assert
        final prefs = await SharedPreferences.getInstance();
        final stored = prefs.getString('ingredients');
        expect(stored, isNotNull);
        expect(stored, contains('Tomato'));
        expect(stored, contains('Onion'));
      });

      test('should save ingredients with all properties', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});
        final ingredients = [
          Ingredient(
            id: 1,
            name: 'Tomato',
            image: 'tomato.jpg',
            amount: 2.5,
            unit: 'cups',
            original: '2.5 cups tomato',
            possibleUnits: ['cup', 'tablespoon'],
          ),
        ];

        // Act
        await localStore.writeIngredients(ingredients);

        // Assert
        final prefs = await SharedPreferences.getInstance();
        final stored = prefs.getString('ingredients');
        expect(stored, contains('2.5'));
        expect(stored, contains('cups'));
        expect(stored, contains('cup'));
        expect(stored, contains('tablespoon'));
      });

      test('should overwrite existing ingredients', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({
          'ingredients': '[{"id": 99, "name": "Old"}]',
        });
        final newIngredients = [Ingredient(id: 1, name: 'New')];

        // Act
        await localStore.writeIngredients(newIngredients);

        // Assert
        final prefs = await SharedPreferences.getInstance();
        final stored = prefs.getString('ingredients');
        expect(stored, contains('New'));
        expect(stored, isNot(contains('Old')));
      });

      test('should save empty list', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({
          'ingredients': '[{"id": 1, "name": "Test"}]',
        });

        // Act
        await localStore.writeIngredients([]);

        // Assert
        final prefs = await SharedPreferences.getInstance();
        final stored = prefs.getString('ingredients');
        expect(stored, '[]');
      });
    });

    group('Integration - Read/Write', () {
      test('should read what was written', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});
        final originalIngredients = [
          Ingredient(
            id: 1,
            name: 'Tomato',
            image: 'tomato.jpg',
            amount: 2.5,
            unit: 'cups',
          ),
          Ingredient(
            id: 2,
            name: 'Onion',
            image: 'onion.jpg',
            amount: 1.0,
            unit: 'piece',
          ),
        ];

        // Act
        await localStore.writeIngredients(originalIngredients);
        final readIngredients = await localStore.readIngredients();

        // Assert
        expect(readIngredients.length, originalIngredients.length);
        expect(readIngredients[0].id, originalIngredients[0].id);
        expect(readIngredients[0].name, originalIngredients[0].name);
        expect(readIngredients[0].amount, originalIngredients[0].amount);
        expect(readIngredients[0].unit, originalIngredients[0].unit);
        expect(readIngredients[1].id, originalIngredients[1].id);
        expect(readIngredients[1].name, originalIngredients[1].name);
      });

      test('should handle multiple write operations', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});
        final firstBatch = [Ingredient(id: 1, name: 'First')];
        final secondBatch = [
          Ingredient(id: 2, name: 'Second'),
          Ingredient(id: 3, name: 'Third'),
        ];

        // Act
        await localStore.writeIngredients(firstBatch);
        await localStore.writeIngredients(secondBatch);
        final result = await localStore.readIngredients();

        // Assert
        expect(result.length, 2);
        expect(result[0].name, 'Second');
        expect(result[1].name, 'Third');
      });
    });
  });
}
