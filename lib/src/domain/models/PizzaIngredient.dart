class PizzaIngredient {
  final int id;
  final String name;
  final int ingredientValue;

  PizzaIngredient({
    required this.id,
    required this.name,
    required this.ingredientValue,
  });

  factory PizzaIngredient.fromJson(Map<String, dynamic> json) {
    return PizzaIngredient(
      id: json['id'],
      name: json['name'],
      ingredientValue: json['ingredientValue'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'id': id,
      'name': name,
      'ingredientValue': ingredientValue,
    };
    return data;
  }
}
