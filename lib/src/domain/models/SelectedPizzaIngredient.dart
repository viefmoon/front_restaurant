import 'package:restaurante/src/domain/models/OrderItem.dart';
import 'package:restaurante/src/domain/models/PizzaIngredient.dart';

enum PizzaHalf { left, right, full }

enum IngredientAction { add, remove }

class SelectedPizzaIngredient {
  final int? id;
  final OrderItem? orderItem;
  final PizzaIngredient? pizzaIngredient;
  final PizzaHalf? half;
  final IngredientAction? action;

  SelectedPizzaIngredient({
    this.id,
    this.orderItem,
    this.pizzaIngredient,
    this.half,
    this.action,
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
              orElse: () => PizzaHalf.full,
            )
          : null,
      action: json['action'] != null
          ? IngredientAction.values.firstWhere(
              (e) => e.toString().split('.').last == json['action'],
              orElse: () => IngredientAction.add,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['pizzaIngredient'] = pizzaIngredient!.toJson();
    if (orderItem != null) {
      data['orderItem'] = orderItem!.toJson();
    }
    data['half'] = half.toString().split('.').last;
    data['action'] = action.toString().split('.').last;

    return data;
  }
}
