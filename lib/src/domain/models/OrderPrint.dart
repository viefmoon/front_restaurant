import 'package:restaurante/src/domain/models/Order.dart'; // Asegúrate de importar correctamente el modelo Order si es necesario

class OrderPrint {
  final int? id;
  final Order? order; // Referencia al pedido
  final String? printedBy; // Quién imprimió el ticket
  final DateTime? printTime; // Momento en que se imprimió el ticket

  OrderPrint({
    this.id,
    this.order,
    this.printedBy,
    this.printTime,
  });

  factory OrderPrint.fromJson(Map<String, dynamic> json) {
    return OrderPrint(
      id: json['id'],
      order: json['order'] != null ? Order.fromJson(json['order']) : null,
      printedBy: json['printedBy'],
      printTime: json['printTime'] != null
          ? DateTime.tryParse(json['printTime'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    if (order != null) data['order'] = order!.toJson();
    data['printedBy'] = printedBy;
    data['printTime'] = printTime?.toIso8601String();
    return data;
  }
}
