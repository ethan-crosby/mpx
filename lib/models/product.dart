import 'ingredient.dart';

class Product {
	final int id;
	final String title;
	final String? image;
	final String? upc;
	final String? breadcrumbs;
	final String? brand;
	final List<Ingredient>? ingredients;
	final Map<String, dynamic>? servings;
	final Map<String, dynamic>? price;

	Product({
		required this.id,
		required this.title,
		this.image,
		this.upc,
		this.breadcrumbs,
		this.brand,
		this.ingredients,
		this.servings,
		this.price,
	});

	factory Product.fromJson(Map<String, dynamic> json) {
		return Product(
			id: json['id'] as int,
			title: json['title'] as String,
			image: json['image'] as String?,
			upc: json['upc'] as String?,
			breadcrumbs: json['breadcrumbs'] as String?,
			brand: json['brand'] as String?,
			ingredients: json['ingredients'] != null
					? (json['ingredients'] as List)
							.map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
							.toList()
					: null,
			servings: json['servings'] as Map<String, dynamic>?,
			price: json['price'] as Map<String, dynamic>?,
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'id': id,
			'title': title,
			'image': image,
			'upc': upc,
			'breadcrumbs': breadcrumbs,
			'brand': brand,
			'ingredients': ingredients?.map((e) => e.toJson()).toList() ?? [],
			'servings': servings,
			'price': price,
		};
	}
}
