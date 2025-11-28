import '../models/product.dart';
import '../models/ingredient.dart';
import '../repositories/spoonacular_repository.dart';

class UPCService {
  final SpoonacularRepository repository;

  UPCService(this.repository);

  Future<Product> getProductByUPC(String upc) async {
    try {
      final data = await repository.getProductByUPC(upc);
      
      int id = 0;
      if (data['id'] != null) {
        if (data['id'] is int) {
          id = data['id'] as int;
        } else if (data['id'] is num) {
          id = (data['id'] as num).toInt();
        } else {
          id = int.tryParse(data['id'].toString()) ?? 0;
        }
      }
      
      final title = (data['title'] as String?) ?? 'Unknown Product';
      
      List<Ingredient>? ingredients;
      if (data['ingredients'] != null && data['ingredients'] is List) {
        try {
          final ingredientsList = data['ingredients'] as List;
          ingredients = ingredientsList
              .where((e) => e != null && e is Map)
              .map((e) {
                try {
                  return Ingredient.fromJson(e as Map<String, dynamic>);
                } catch (err) {
                  final map = e as Map<String, dynamic>;
                  final name = map['name'] as String? ?? 
                              map['originalName'] as String? ??
                              'Unknown';
                  return Ingredient(id: 0, name: name);
                }
              })
              .toList();
        } catch (e) {
          // ignore
        }
      }
      
      if ((ingredients == null || ingredients.isEmpty) && data['ingredientList'] != null) {
        final ingredientListStr = data['ingredientList'] as String?;
        if (ingredientListStr != null && ingredientListStr.isNotEmpty) {
          final names = ingredientListStr.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
          ingredients = names.map((name) => Ingredient(
            id: 0,
            name: name,
          )).toList();
        }
      }
      
      final product = Product(
        id: id,
        title: title,
        image: data['image'] as String?,
        upc: data['upc'] as String? ?? upc,
        ingredients: ingredients,
      );

      return product;
    } catch (e) {
      throw Exception('Failed to get product by UPC: $e');
    }
  }

  Future<List<String>> getIngredientsFromUPC(String upc) async {
    final product = await getProductByUPC(upc);
    
    if (product.ingredients == null || product.ingredients!.isEmpty) {
      return [];
    }

    return product.ingredients!
        .map((ingredient) => ingredient.name)
        .where((name) => name.isNotEmpty)
        .toList();
  }
}

