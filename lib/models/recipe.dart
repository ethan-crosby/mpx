import 'ingredient.dart';

class Recipe {
  final int id;
  final String title;
  final String? image;
  final int? usedIngredientCount;
  final int? missedIngredientCount;
  final List<Ingredient>? missedIngredients;
  final List<Ingredient>? usedIngredients;
  final int? likes;

  Recipe({
    required this.id,
    required this.title,
    this.image,
    this.usedIngredientCount,
    this.missedIngredientCount,
    this.missedIngredients,
    this.usedIngredients,
    this.likes,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as int,
      title: json['title'] as String,
      image: json['image'] as String?,
      usedIngredientCount: json['usedIngredientCount'] as int?,
      missedIngredientCount: json['missedIngredientCount'] as int?,
      missedIngredients: json['missedIngredients'] != null
          ? (json['missedIngredients'] as List)
              .map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      usedIngredients: json['usedIngredients'] != null
          ? (json['usedIngredients'] as List)
              .map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      likes: json['likes'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image': image,
      'usedIngredientCount': usedIngredientCount,
      'missedIngredientCount': missedIngredientCount,
      'missedIngredients': missedIngredients?.map((e) => e.toJson()).toList() ?? [],
      'usedIngredients': usedIngredients?.map((e) => e.toJson()).toList() ?? [],
      'likes': likes,
    };
  }
}

