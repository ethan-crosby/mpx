import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mpx/models/ingredient.dart';
import 'package:mpx/services/ingredient_service.dart';
import 'package:mpx/storage/localStore.dart';
import 'package:mpx/viewModels/ingredientVM.dart';

import 'ingredient_vm_test.mocks.dart';

@GenerateMocks([IngredientService, LocalStore])
void main() {
  late MockIngredientService mockService;
  late MockLocalStore mockStore;

  setUp(() {
    mockService = MockIngredientService();
    mockStore = MockLocalStore();
  });

  group('IngredientVM Tests', () {
    test('should initialize with loading state', () async {
      // Ala Dr. Biehl's Testing UIs - Slide 5
      // Arrange
      when(mockStore.readIngredients()).thenAnswer((_) async => []);

      // Act
      final vm = IngredientVM(mockService, mockStore);

      // Initial state before init completes
      expect(vm.loading, true);

      // Wait for init to complete
      await Future.delayed(Duration(milliseconds: 100));

      // Assert
      expect(vm.loading, false);
      verify(mockStore.readIngredients()).called(1);
    });

    test('should load ingredients from storage on init', () async {
      // Arrange
      final storedIngredients = [
        Ingredient(id: 1, name: 'Tomato'),
        Ingredient(id: 2, name: 'Onion'),
      ];

      when(
        mockStore.readIngredients(),
      ).thenAnswer((_) async => storedIngredients);

      // Act
      final vm = IngredientVM(mockService, mockStore);
      await Future.delayed(Duration(milliseconds: 100));

      // Assert
      expect(vm.ingredients.length, 2);
      expect(vm.ingredients[0].name, 'Tomato');
      expect(vm.ingredients[1].name, 'Onion');
      expect(vm.loading, false);
    });

    test('should load empty list when storage is empty', () async {
      // Arrange
      when(mockStore.readIngredients()).thenAnswer((_) async => []);

      // Act
      final vm = IngredientVM(mockService, mockStore);
      await Future.delayed(Duration(milliseconds: 100));

      // Assert
      expect(vm.ingredients, isEmpty);
      expect(vm.loading, false);
    });

    test('should add ingredient and save to storage', () async {
      // Arrange
      when(mockStore.readIngredients()).thenAnswer((_) async => []);
      when(mockStore.writeIngredients(any)).thenAnswer((_) async => {});

      final vm = IngredientVM(mockService, mockStore);
      await Future.delayed(Duration(milliseconds: 100));

      final newIngredient = Ingredient(id: 1, name: 'Tomato');
      bool notified = false;
      vm.addListener(() => notified = true);

      // Act
      vm.addIngredient(newIngredient);

      // Assert
      expect(vm.ingredients.length, 1);
      expect(vm.ingredients[0].name, 'Tomato');
      expect(notified, true);
      verify(mockStore.writeIngredients(any)).called(1);
    });

    test('should add multiple ingredients', () async {
      // Arrange
      when(mockStore.readIngredients()).thenAnswer((_) async => []);
      when(mockStore.writeIngredients(any)).thenAnswer((_) async => {});

      final vm = IngredientVM(mockService, mockStore);
      await Future.delayed(Duration(milliseconds: 100));

      // Act
      vm.addIngredient(Ingredient(id: 1, name: 'Tomato'));
      vm.addIngredient(Ingredient(id: 2, name: 'Onion'));
      vm.addIngredient(Ingredient(id: 3, name: 'Garlic'));

      // Assert
      expect(vm.ingredients.length, 3);
      verify(mockStore.writeIngredients(any)).called(3);
    });

    test('should remove ingredient and update storage', () async {
      // Arrange
      final initialIngredients = [
        Ingredient(id: 1, name: 'Tomato'),
        Ingredient(id: 2, name: 'Onion'),
      ];

      when(
        mockStore.readIngredients(),
      ).thenAnswer((_) async => initialIngredients);
      when(mockStore.writeIngredients(any)).thenAnswer((_) async => {});

      final vm = IngredientVM(mockService, mockStore);
      await Future.delayed(Duration(milliseconds: 100));

      bool notified = false;
      vm.addListener(() => notified = true);

      // Act
      vm.removeIngredient(initialIngredients[0]);

      // Assert
      expect(vm.ingredients.length, 1);
      expect(vm.ingredients[0].name, 'Onion');
      expect(notified, true);
      verify(mockStore.writeIngredients(any)).called(1);
    });

    test('should handle removing non-existent ingredient', () async {
      // Arrange
      when(
        mockStore.readIngredients(),
      ).thenAnswer((_) async => [Ingredient(id: 1, name: 'Tomato')]);
      when(mockStore.writeIngredients(any)).thenAnswer((_) async => {});

      final vm = IngredientVM(mockService, mockStore);
      await Future.delayed(Duration(milliseconds: 100));

      final nonExistent = Ingredient(id: 99, name: 'NotThere');

      // Act
      vm.removeIngredient(nonExistent);

      // Assert - should still have original ingredient
      expect(vm.ingredients.length, 1);
      expect(vm.ingredients[0].name, 'Tomato');
    });

    test('should notify listeners when changeAmount is called', () async {
      // Arrange
      when(mockStore.readIngredients()).thenAnswer((_) async => []);

      final vm = IngredientVM(mockService, mockStore);
      await Future.delayed(Duration(milliseconds: 100));

      bool notified = false;
      vm.addListener(() => notified = true);

      // Act
      vm.changeAmount();

      // Assert
      expect(notified, true);
    });

    test('should set loading state during add operation', () async {
      // Arrange
      when(mockStore.readIngredients()).thenAnswer((_) async => []);
      when(mockStore.writeIngredients(any)).thenAnswer((_) async => {});

      final vm = IngredientVM(mockService, mockStore);
      await Future.delayed(Duration(milliseconds: 100));

      bool loadingStateSeen = false;
      vm.addListener(() {
        if (vm.loading) loadingStateSeen = true;
      });

      // Act
      vm.addIngredient(Ingredient(id: 1, name: 'Tomato'));

      // Assert
      expect(loadingStateSeen, true);
      expect(vm.loading, false); // Should be false after operation
    });

    test('should set loading state during remove operation', () async {
      // Arrange
      final ingredient = Ingredient(id: 1, name: 'Tomato');
      when(mockStore.readIngredients()).thenAnswer((_) async => [ingredient]);
      when(mockStore.writeIngredients(any)).thenAnswer((_) async => {});

      final vm = IngredientVM(mockService, mockStore);
      await Future.delayed(Duration(milliseconds: 100));

      bool loadingStateSeen = false;
      vm.addListener(() {
        if (vm.loading) loadingStateSeen = true;
      });

      // Act
      vm.removeIngredient(ingredient);

      // Assert
      expect(loadingStateSeen, true);
      expect(vm.loading, false); // Should be false after operation
    });

    test('should notify listeners multiple times during operations', () async {
      // Arrange
      when(mockStore.readIngredients()).thenAnswer((_) async => []);
      when(mockStore.writeIngredients(any)).thenAnswer((_) async => {});

      final vm = IngredientVM(mockService, mockStore);
      await Future.delayed(Duration(milliseconds: 100));

      int notifyCount = 0;
      vm.addListener(() => notifyCount++);

      // Act
      vm.addIngredient(Ingredient(id: 1, name: 'Tomato'));

      // Assert - should notify at least twice (loading true, loading false)
      expect(notifyCount, greaterThanOrEqualTo(2));
    });
  });
}
