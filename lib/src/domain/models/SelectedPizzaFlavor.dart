import 'package:restaurante/src/domain/models/OrderItem.dart';
import 'package:restaurante/src/domain/models/PizzaFlavor.dart';

class SelectedPizzaFlavor {
  final int? id;
  final OrderItem? orderItem;
  final PizzaFlavor? pizzaFlavor;

  SelectedPizzaFlavor({
    this.id,
    this.orderItem,
    this.pizzaFlavor,
  });

  factory SelectedPizzaFlavor.fromJson(Map<String, dynamic> json) {
    return SelectedPizzaFlavor(
      id: json['id'],
      pizzaFlavor: json['pizzaFlavor'] != null
          ? PizzaFlavor.fromJson(json['pizzaFlavor'])
          : null,
      orderItem: json['orderItem'] != null
          ? OrderItem.fromJson(json['orderItem'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['pizzaFlavor'] = pizzaFlavor!.toJson();
    if (orderItem != null) {
      data['orderItem'] = orderItem!.toJson();
    }
    return data;
  }
}
