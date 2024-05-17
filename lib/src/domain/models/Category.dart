import 'package:restaurante/src/domain/models/Subcategory.dart';

class Category {
  final int id;
  final String name; // 'name' ahora es no nulo
  List<Subcategory>? subcategories;

  Category({
    required this.id,
    required this.name, // Hacemos 'name' requerido
    this.subcategories,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name']
          as String, // Aseguramos que 'name' sea tratado como String no nulo
      // Simplificamos la inicialización de 'subcategories'
      subcategories: json['subcategories'] != null
          ? (json['subcategories'] as List)
              .map((i) => Subcategory.fromJson(i))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'id': id,
      'name': name, // 'name' es siempre no nulo
    };
    // Simplificamos la conversión de 'subcategories' a JSON
    data['subcategories'] = subcategories?.map((v) => v.toJson()).toList();
    return data;
  }
}
