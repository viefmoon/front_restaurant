import 'package:restaurante/src/domain/models/OrderItem.dart';
import 'package:restaurante/src/domain/models/OrderUpdate.dart';

class OrderItemUpdate {
  final int? id;
  OrderItem? orderItem; // Relación ManyToOne con OrderItem
  OrderUpdate? orderUpdate; // Relación ManyToOne con OrderUpdate

  OrderItemUpdate({
    required this.id,
    this.orderItem,
    this.orderUpdate,
  });

  factory OrderItemUpdate.fromJson(Map<String, dynamic> json) {
    return OrderItemUpdate(
      id: json['id'],
      orderItem: json['orderItem'] != null
          ? OrderItem.fromJson(json['orderItem'])
          : null,
      orderUpdate: json['orderUpdate'] != null
          ? OrderUpdate.fromJson(json['orderUpdate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    if (orderItem != null) data['orderItem'] = orderItem!.toJson();
    if (orderUpdate != null) data['orderUpdate'] = orderUpdate!.toJson();
    return data;
  }
}
