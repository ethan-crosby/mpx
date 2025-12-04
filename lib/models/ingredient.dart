class Ingredient {
	final int id;
	final String name;
	final String? image;
	final double? amount;
	final String? unit;
	final String? original;

	Ingredient({
		required this.id,
		required this.name,
		this.image,
		this.amount,
		this.unit,
		this.original,
	});

	factory Ingredient.fromJson(Map<String, dynamic> json) {
		return Ingredient(
			id: json['id'] as int,
			name: json['name'] as String,
			image: json['image'] as String?,
			amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
			unit: json['unit'] as String?,
			original: json['original'] as String?,
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'id': id,
			'name': name,
			'image': image,
			'amount': amount,
			'unit': unit,
			'original': original,
		};
	}
}

