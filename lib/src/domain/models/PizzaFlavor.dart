import 'package:restaurante/src/domain/models/SelectedPizzaIngredient.dart';

class PizzaFlavor {
  final String id;
  final String name;
  final PizzaHalf? half;
  final double? price; // 'price' ahora puede ser nulo

  PizzaFlavor({
    required this.id,
    required this.name,
    this.half,
    this.price, // 'price' ya no es requerido
  });

  factory PizzaFlavor.fromJson(Map<String, dynamic> json) {
    return PizzaFlavor(
      id: json['id'],
      name: json['name'],
      half: json['half'] != null
          ? PizzaHalf.values.firstWhere(
              (e) => e.toString().split('.').last == json['half'],
              orElse: () => PizzaHalf.full,
            )
          : null,
      price: json['price'] != null
          ? double.tryParse(json['price'].toString())
          : null, // Manejo seguro de 'price'
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'id': id,
      'name': name,
      'half': half?.toString().split('.').last,
      'price':
          price, // 'price' puede ser nulo, así que está bien incluirlo directamente
    };
    return data;
  }
}
