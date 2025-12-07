import 'package:flutter_test/flutter_test.dart';
import 'package:mpx/models/ingredient.dart';

void main() {
  group('Ingredient Model Tests', () {
    test('should create an Ingredient from JSON', () {
      // Ala Dr. Biehl's Testing UIs - Slide 5
      // Arrange
      final json = {
        'id': 1,
        'name': 'Tomato',
        'image': 'tomato.jpg',
        'amount': 2.5,
        'unit': 'cups',
        'original': '2.5 cups of tomato',
        'possibleUnits': ['cup', 'tablespoon', 'teaspoon'],
      };

      // Act
      final ingredient = Ingredient.fromJson(json);

      // Assert
      expect(ingredient.id, 1);
      expect(ingredient.name, 'Tomato');
      expect(ingredient.image, 'tomato.jpg');
      expect(ingredient.amount, 2.5);
      expect(ingredient.unit, 'cups');
      expect(ingredient.original, '2.5 cups of tomato');
      expect(ingredient.possibleUnits, ['cup', 'tablespoon', 'teaspoon']);
    });

    test('should create an Ingredient from JSON with null values', () {
      // Arrange
      final json = {'id': 1, 'name': 'Tomato'};

      // Act
      final ingredient = Ingredient.fromJson(json);

      // Assert
      expect(ingredient.id, 1);
      expect(ingredient.name, 'Tomato');
      expect(ingredient.image, null);
      expect(ingredient.amount, null);
      expect(ingredient.unit, null);
      expect(ingredient.original, null);
      expect(ingredient.possibleUnits, null);
    });

    test('should convert Ingredient to JSON', () {
      // Arrange
      final ingredient = Ingredient(
        id: 1,
        name: 'Tomato',
        image: 'tomato.jpg',
        amount: 2.5,
        unit: 'cups',
        original: '2.5 cups of tomato',
        possibleUnits: ['cup', 'tablespoon', 'teaspoon'],
      );

      // Act
      final json = ingredient.toJson();

      // Assert
      expect(json['id'], 1);
      expect(json['name'], 'Tomato');
      expect(json['image'], 'tomato.jpg');
      expect(json['amount'], 2.5);
      expect(json['unit'], 'cups');
      expect(json['original'], '2.5 cups of tomato');
      expect(json['possibleUnits'], ['cup', 'tablespoon', 'teaspoon']);
    });

    test('should handle amount as int from JSON', () {
      // Arrange
      final json = {
        'id': 1,
        'name': 'Tomato',
        'amount': 2, // int instead of double
      };

      // Act
      final ingredient = Ingredient.fromJson(json);

      // Assert
      expect(ingredient.amount, 2.0);
    });

    test('should create Ingredient with required fields only', () {
      // Arrange & Act
      final ingredient = Ingredient(id: 1, name: 'Tomato');

      // Assert
      expect(ingredient.id, 1);
      expect(ingredient.name, 'Tomato');
      expect(ingredient.image, null);
      expect(ingredient.amount, null);
      expect(ingredient.unit, null);
    });

    test('should allow modifying amount and unit after creation', () {
      // Arrange
      final ingredient = Ingredient(id: 1, name: 'Tomato');

      // Act
      ingredient.amount = 3.0;
      ingredient.unit = 'pounds';

      // Assert
      expect(ingredient.amount, 3.0);
      expect(ingredient.unit, 'pounds');
    });
  });
}
