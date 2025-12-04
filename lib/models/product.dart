import 'ingredient.dart';

class Product {
	final int id;
	final String title;
	final String? image;
	final String? upc;
	final List<Ingredient>? ingredients;

	Product({
		required this.id,
		required this.title,
		this.image,
		this.upc,
		this.ingredients,
	});

	factory Product.fromJson(Map<String, dynamic> json) {
		return Product(
			id: json['id'] as int,
			title: json['title'] as String,
			image: json['image'] as String?,
			upc: json['upc'] as String?,
			ingredients: json['ingredients'] != null
					? (json['ingredients'] as List)
							.map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
							.toList()
					: null,
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'id': id,
			'title': title,
			'image': image,
			'upc': upc,
			'ingredients': ingredients?.map((e) => e.toJson()).toList() ?? [],
		};
	}
}

