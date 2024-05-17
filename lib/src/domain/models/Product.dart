import 'package:restaurante/src/domain/models/ModifierType.dart';
import 'package:restaurante/src/domain/models/OrderItem.dart';
import 'package:restaurante/src/domain/models/PizzaFlavor.dart';
import 'package:restaurante/src/domain/models/PizzaIngredient.dart';
import 'package:restaurante/src/domain/models/ProductObservationType.dart';
import 'package:restaurante/src/domain/models/ProductVariant.dart';
import 'package:restaurante/src/domain/models/Subcategory.dart';

class Product {
  final int id;
  final String name;
  final double? price;
  final String? imageUrl;
  Subcategory? subcategory;
  List<ProductVariant>? productVariants;
  List<ModifierType>? modifierTypes;
  List<ProductObservationType>? productObservationTypes;
  List<PizzaFlavor>? pizzaFlavors;
  List<PizzaIngredient>? pizzaIngredients;
  List<OrderItem>? orderItems;

  Product({
    required this.id,
    required this.name,
    this.price,
    this.imageUrl,
    this.subcategory,
    this.productVariants,
    this.modifierTypes,
    this.productObservationTypes,
    this.pizzaFlavors,
    this.pizzaIngredients,
    this.orderItems,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: json['price'] != null ? double.parse(json['price']) : null,
      imageUrl: json['imageUrl'],
      subcategory: json['subcategory'] != null
          ? Subcategory.fromJson(json['subcategory'])
          : null,
      productVariants: json['productVariants'] != null
          ? (json['productVariants'] as List)
              .map((i) => ProductVariant.fromJson(i))
              .toList()
          : null,
      modifierTypes: json['modifierTypes'] != null
          ? (json['modifierTypes'] as List)
              .map((i) => ModifierType.fromJson(i))
              .toList()
          : null,
      productObservationTypes: json['productObservationTypes'] != null
          ? (json['productObservationTypes'] as List)
              .map((i) => ProductObservationType.fromJson(i))
              .toList()
          : null,
      pizzaFlavors: json['pizzaFlavors'] != null
          ? (json['pizzaFlavors'] as List)
              .map((i) => PizzaFlavor.fromJson(i))
              .toList()
          : null,
      pizzaIngredients: json['pizzaIngredients'] != null
          ? (json['pizzaIngredients'] as List)
              .map((i) => PizzaIngredient.fromJson(i))
              .toList()
          : null,
      orderItems: json['orderItems'] != null
          ? (json['orderItems'] as List)
              .map((i) => OrderItem.fromJson(i))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['name'] = name;
    data['price'] = price;
    data['imageUrl'] = imageUrl;
    if (subcategory != null) {
      data['subcategory'] = subcategory!.toJson();
    }
    if (productVariants != null) {
      data['productVariants'] =
          productVariants!.map((v) => v.toJson()).toList();
    }
    if (modifierTypes != null) {
      data['modifierTypes'] = modifierTypes!.map((v) => v.toJson()).toList();
    }
    if (productObservationTypes != null) {
      data['productObservationTypes'] =
          productObservationTypes!.map((v) => v.toJson()).toList();
    }
    if (pizzaFlavors != null) {
      data['pizzaFlavors'] = pizzaFlavors!.map((v) => v.toJson()).toList();
    }
    if (pizzaIngredients != null) {
      data['pizzaIngredients'] =
          pizzaIngredients!.map((v) => v.toJson()).toList();
    }
    if (orderItems != null) {
      data['orderItems'] = orderItems!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  Product copyWith({
    int? id,
    String? name,
    double? price,
    String? imageUrl,
    Subcategory? subcategory,
    List<ProductVariant>? productVariants,
    List<ModifierType>? modifierTypes,
    List<ProductObservationType>? productObservationTypes,
    List<PizzaFlavor>? pizzaFlavors,
    List<PizzaIngredient>? pizzaIngredients,
    List<OrderItem>? orderItems,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      subcategory: subcategory ?? this.subcategory,
      productVariants: productVariants ?? this.productVariants,
      modifierTypes: modifierTypes ?? this.modifierTypes,
      productObservationTypes:
          productObservationTypes ?? this.productObservationTypes,
      pizzaFlavors: pizzaFlavors ?? this.pizzaFlavors,
      pizzaIngredients: pizzaIngredients ?? this.pizzaIngredients,
      orderItems: orderItems ?? this.orderItems,
    );
  }
}
