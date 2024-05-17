import 'package:restaurante/src/domain/models/OrderItem.dart';
import 'package:restaurante/src/domain/models/ProductObservation.dart';

class SelectedProductObservation {
  final int? id; // 'id' ahora puede ser nulo
  final OrderItem? orderItem;
  final ProductObservation? productObservation;

  SelectedProductObservation({
    this.id, // 'id' ya no es requerido
    this.orderItem,
    this.productObservation, // 'productObservation' es requerido
  });

  factory SelectedProductObservation.fromJson(Map<String, dynamic> json) {
    return SelectedProductObservation(
      id: json['id'],
      orderItem: json['orderItem'] != null
          ? OrderItem.fromJson(json['orderItem'])
          : null,
      productObservation: json['productObservation'] != null
          ? ProductObservation.fromJson(json['productObservation'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (id != null) {
      // Incluir 'id' solo si no es nulo
      data['id'] = id;
    }
    // 'productObservation' siempre se incluye ya que es requerido
    data['productObservation'] = productObservation!.toJson();
    if (orderItem != null) {
      data['orderItem'] = orderItem!.toJson();
    }
    return data;
  }
}
