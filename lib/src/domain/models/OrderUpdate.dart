import 'package:restaurante/src/domain/models/OrderItemUpdate.dart';
import 'package:restaurante/src/domain/models/Order.dart' as OrderModel;

class OrderUpdate {
  final int id;
  final DateTime updateAt; // Uso de DateTime para fechas
  final int updateNumber;
  final String? updatedBy;
  OrderModel.Order? order; // Relación ManyToOne con Order
  List<OrderItemUpdate>?
      orderItemUpdates; // Relación OneToMany con OrderItemUpdate

  OrderUpdate({
    required this.id,
    required this.updateAt,
    required this.updateNumber,
    required this.updatedBy,
    this.order,
    this.orderItemUpdates,
  });

  factory OrderUpdate.fromJson(Map<String, dynamic> json) {
    return OrderUpdate(
      id: json['id'],
      updateAt: DateTime.parse(json['updateAt']),
      // Asumiendo la existencia de método fromJson para Order
      updateNumber: json['updateNumber'],
      updatedBy: json['updatedBy'],
      order: json['order'] != null
          ? OrderModel.Order.fromJson(json['order'])
          : null,
      orderItemUpdates: json['orderItemUpdates'] != null
          ? (json['orderItemUpdates'] as List)
              .map((i) => OrderItemUpdate.fromJson(i))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['updateAt'] = updateAt.toIso8601String();
    data['updateNumber'] = updateNumber;
    data['updatedBy'] = updatedBy;
    if (order != null) data['order'] = order!.toJson();
    if (orderItemUpdates != null) {
      data['orderItemUpdates'] =
          orderItemUpdates!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
