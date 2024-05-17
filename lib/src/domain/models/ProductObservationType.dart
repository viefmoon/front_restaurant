import 'package:restaurante/src/domain/models/ProductObservation.dart';

class ProductObservationType {
  final int id;
  final String name;
  final bool acceptsMultiple; // 'acceptsMultiple' ahora es no nulo y requerido
  List<ProductObservation>? productObservations;

  ProductObservationType({
    required this.id,
    required this.name,
    required this.acceptsMultiple, // 'acceptsMultiple' es ahora un parámetro requerido
    this.productObservations,
  });

  factory ProductObservationType.fromJson(Map<String, dynamic> json) {
    return ProductObservationType(
      id: json['id'],
      name: json['name'],
      acceptsMultiple: json['acceptsMultiple'] ??
          false, // Proporciona un valor predeterminado si falta
      productObservations: (json['productObservations'] as List?)
          ?.map((i) => ProductObservation.fromJson(i))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'id': id,
      'name': name,
      'acceptsMultiple':
          acceptsMultiple, // Ya no es necesario marcarlo como que puede ser nulo
    };
    if (productObservations != null) {
      data['productObservations'] =
          productObservations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
