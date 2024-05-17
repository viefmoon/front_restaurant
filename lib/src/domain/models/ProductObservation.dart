import 'package:restaurante/src/domain/models/ProductObservationType.dart';

class ProductObservation {
  final int id;
  final String name;
  ProductObservationType? productObservationType;

  ProductObservation({
    required this.id,
    required this.name,
    this.productObservationType,
  });

  factory ProductObservation.fromJson(Map<String, dynamic> json) {
    return ProductObservation(
      id: json['id'],
      name: json['name'],
      productObservationType: json['productObservationType'] != null
          ? ProductObservationType.fromJson(json['productObservationType'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    if (productObservationType != null) {
      data['productObservationType'] = productObservationType!.toJson();
    }
    return data;
  }
}
