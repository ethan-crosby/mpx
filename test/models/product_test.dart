import 'package:flutter_test/flutter_test.dart';
import 'package:mpx/models/ingredient.dart';
import 'package:mpx/models/product.dart';

void main() {
  group('Product Model Tests', () {
    test('should create a Product from JSON', () {
      // Ala Dr. Biehl's Testing UIs - Slide 5
      // Arrange
      final json = {
        'id': 1,
        'title': 'Organic Tomato Sauce',
        'image': 'sauce.jpg',
        'upc': '012345678901',
        'breadcrumbs': ['Food', 'Condiments', 'Sauces'],
        'brand': 'OrganicBrand',
        'ingredients': [
          {'id': 1, 'name': 'Tomatoes'},
          {'id': 2, 'name': 'Salt'},
        ],
        'servings': {'number': 4.0, 'size': 2.0, 'unit': 'tbsp'},
        'price': {'value': 4.99, 'unit': 'US Dollar'},
      };

      // Act
      final product = Product.fromJson(json);

      // Assert
      expect(product.id, 1);
      expect(product.title, 'Organic Tomato Sauce');
      expect(product.image, 'sauce.jpg');
      expect(product.upc, '012345678901');
      expect(product.breadcrumbs, ['Food', 'Condiments', 'Sauces']);
      expect(product.brand, 'OrganicBrand');
      expect(product.ingredients?.length, 2);
      expect(product.ingredients?[0].name, 'Tomatoes');
      expect(product.servings, isA<Map<String, dynamic>>());
      expect(product.price, isA<Map<String, dynamic>>());
    });

    test('should create a Product from JSON with null values', () {
      // Arrange
      final json = {'id': 1, 'title': 'Basic Product'};

      // Act
      final product = Product.fromJson(json);

      // Assert
      expect(product.id, 1);
      expect(product.title, 'Basic Product');
      expect(product.image, null);
      expect(product.upc, null);
      expect(product.breadcrumbs, null);
      expect(product.brand, null);
      expect(product.ingredients, null);
      expect(product.servings, null);
      expect(product.price, null);
    });

    test('should handle breadcrumbs as single string', () {
      // Arrange
      final json = {'id': 1, 'title': 'Product', 'breadcrumbs': 'Food'};

      // Act
      final product = Product.fromJson(json);

      // Assert
      expect(product.breadcrumbs, ['Food']);
    });

    test('should handle breadcrumbs as list', () {
      // Arrange
      final json = {
        'id': 1,
        'title': 'Product',
        'breadcrumbs': ['Food', 'Snacks'],
      };

      // Act
      final product = Product.fromJson(json);

      // Assert
      expect(product.breadcrumbs, ['Food', 'Snacks']);
    });

    test('should convert Product to JSON', () {
      // Arrange
      final product = Product(
        id: 1,
        title: 'Organic Tomato Sauce',
        image: 'sauce.jpg',
        upc: '012345678901',
        breadcrumbs: ['Food', 'Condiments'],
        brand: 'OrganicBrand',
        ingredients: [
          Ingredient(id: 1, name: 'Tomatoes'),
          Ingredient(id: 2, name: 'Salt'),
        ],
        servings: {'number': 4.0},
        price: {'value': 4.99},
      );

      // Act
      final json = product.toJson();

      // Assert
      expect(json['id'], 1);
      expect(json['title'], 'Organic Tomato Sauce');
      expect(json['image'], 'sauce.jpg');
      expect(json['upc'], '012345678901');
      expect(json['breadcrumbs'], ['Food', 'Condiments']);
      expect(json['brand'], 'OrganicBrand');
      expect(json['ingredients'], isA<List>());
      expect((json['ingredients'] as List).length, 2);
      expect(json['servings'], {'number': 4.0});
      expect(json['price'], {'value': 4.99});
    });

    test('should handle empty ingredients in toJson', () {
      // Arrange
      final product = Product(id: 1, title: 'Product');

      // Act
      final json = product.toJson();

      // Assert
      expect(json['ingredients'], isEmpty);
    });

    test('should create Product with required fields only', () {
      // Arrange & Act
      final product = Product(id: 1, title: 'Product');

      // Assert
      expect(product.id, 1);
      expect(product.title, 'Product');
      expect(product.image, null);
      expect(product.upc, null);
      expect(product.breadcrumbs, null);
      expect(product.brand, null);
      expect(product.ingredients, null);
    });

    test('should handle empty ingredient list from JSON', () {
      // Arrange
      final json = {'id': 1, 'title': 'Product', 'ingredients': []};

      // Act
      final product = Product.fromJson(json);

      // Assert
      expect(product.ingredients, isEmpty);
    });
  });
}
