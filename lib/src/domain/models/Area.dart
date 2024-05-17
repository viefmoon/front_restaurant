import 'Table.dart';

class Area {
  final int id;
  final String? name;
  final List<Table>? tables;

  Area({required this.id, this.name, this.tables});

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      id: json['id'],
      name: json['name'],
      // Simplificamos la inicialización de 'tables' para mejorar la legibilidad
      tables: (json['tables'] as List?)?.map((i) => Table.fromJson(i)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['name'] = name;
    // Usamos el operador '?.' para simplificar la comprobación de nulidad
    data['tables'] = tables?.map((v) => v.toJson()).toList();
    return data;
  }
}
