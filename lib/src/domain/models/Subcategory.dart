import 'package:restaurante/src/domain/models/Product.dart';
import 'package:restaurante/src/domain/models/Category.dart' as CategoryModel;

class Subcategory {
  final int id;
  final String name;
  CategoryModel.Category?
      category; // Referencia opcional a Category para mantener la relación
  List<Product>?
      products; // Lista de productos pertenecientes a esta subcategoría

  Subcategory({
    required this.id,
    required this.name,
    this.category,
    this.products,
  });

  factory Subcategory.fromJson(Map<String, dynamic> json) {
    return Subcategory(
      id: json['id'],
      name: json['name'],
      // Asume que Category.fromJson es un método estático para deserializar una categoría
      category: json['category'] != null
          ? CategoryModel.Category.fromJson(json['category'])
          : null,
      // Deserializa la lista de productos si está disponible
      products: json['products'] != null
          ? (json['products'] as List).map((i) => Product.fromJson(i)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['name'] = name;
    // Serializa 'category' solo si no es nulo
    if (category != null) {
      data['category'] = category!.toJson();
    }
    // Serializa 'products' solo si no es nulo
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
