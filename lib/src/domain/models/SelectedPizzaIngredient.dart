import 'package:restaurante/src/domain/models/OrderItem.dart';
import 'package:restaurante/src/domain/models/PizzaIngredient.dart';

enum PizzaHalf { left, right, none }

class SelectedPizzaIngredient {
  final int? id;
  final OrderItem? orderItem;
  final PizzaIngredient? pizzaIngredient;
  final PizzaHalf? half;

  SelectedPizzaIngredient({
    this.id,
    this.orderItem,
    this.pizzaIngredient,
    this.half,
  });

  factory SelectedPizzaIngredient.fromJson(Map<String, dynamic> json) {
    return SelectedPizzaIngredient(
      id: json['id'],
      pizzaIngredient: json['pizzaIngredient'] != null
          ? PizzaIngredient.fromJson(json['pizzaIngredient'])
          : null,
      orderItem: json['orderItem'] != null
          ? OrderItem.fromJson(json['orderItem'])
          : null,
      half: json['half'] != null
          ? PizzaHalf.values.firstWhere(
              (e) => e.toString().split('.').last == json['half'],
              orElse: () => PizzaHalf
                  .none, // Proporciona un valor predeterminado si 'half' no está presente
            )
          : null, // Retorna null si 'half' no está en el JSON
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['pizzaIngredient'] = pizzaIngredient!.toJson();
    if (orderItem != null) {
      data['orderItem'] = orderItem!.toJson();
    }
    data['half'] = half
        .toString()
        .split('.')
        .last; // Conversión de enum a String para JSON

    return data;
  }
}
