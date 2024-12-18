import 'package:restaurante/src/domain/models/ModifierType.dart';

class Modifier {
  final String id;
  final String name; // Ahora 'name' es no nulo
  final String shortName;
  final double? price;
  final ModifierType? modifierType;

  Modifier({
    required this.id,
    required this.name, // 'name' es requerido
    required this.shortName,
    this.price,
    this.modifierType,
  });

  factory Modifier.fromJson(Map<String, dynamic> json) {
    return Modifier(
      id: json['id'],
      name: json[
          'name'], // Asumimos que 'name' siempre está presente y es no nulo
      shortName: json['shortName'],
      price: json['price'] != null
          ? double.tryParse(json['price'].toString())
          : null, // Manejo seguro de 'price'
      modifierType: json['modifierType'] != null
          ? ModifierType.fromJson(json['modifierType'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'id': id,
      'name': name, // 'name' siempre se incluye
      'shortName': shortName,
      'price':
          price, // 'price' puede ser nulo, así que está bien incluirlo directamente
    };
    if (modifierType != null) {
      data['modifierType'] = modifierType!.toJson();
    }
    return data;
  }
}
