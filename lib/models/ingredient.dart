class Ingredient {
	final int id;
	final String name;
	final String? image;
	double? amount;
	String? unit;
	final String? original;

	Ingredient({
		required this.id,
		required this.name,
		this.image,
		this.amount,
		this.unit,
		this.original,
		this.possibleUnits,
	});

	factory Ingredient.fromJson(Map<String, dynamic> json) {
		return Ingredient(
			id: json['id'] as int,
			name: json['name'] as String,
			image: json['image'] as String?,
			amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
			unit: json['unit'] as String?,
			original: json['original'] as String?,
			possibleUnits: json['possibleUnits'] != null
				? List<String>.from(json['possibleUnits'])
				: null,

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
			'possibleUnits': possibleUnits,
		};
	}
}

