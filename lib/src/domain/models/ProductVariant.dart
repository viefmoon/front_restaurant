import 'package:restaurante/src/domain/models/OrderItem.dart';
import 'package:restaurante/src/domain/models/Product.dart';

class ProductVariant {
  final int id;
  final String name;
  final double? price;
  Product? product; // Relación ManyToOne con Product
  List<OrderItem>? orderItems; // Relación OneToMany con OrderItem

  ProductVariant({
    required this.id,
    required this.name,
    this.price, // Hacemos que 'price' sea opcional en el constructor
    this.product,
    this.orderItems,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'],
      name: json['name'],
      price: json['price'] != null
          ? double.tryParse(json['price'].toString())
          : null,
      product:
          json['product'] != null ? Product.fromJson(json['product']) : null,
      orderItems: json['orderItems'] != null
          ? (json['orderItems'] as List)
              .map((i) => OrderItem.fromJson(i))
              .toList()
          : null,
    );
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'id': id,
      'name': name,
      'price': price, // No es necesario cambiar nada aquí
    };
    if (product != null) {
      data['product'] = product!.toJson();
    }
    if (orderItems != null) {
      data['orderItems'] = orderItems!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
