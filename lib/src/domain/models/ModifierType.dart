import 'package:restaurante/src/domain/models/Modifier.dart';

class ModifierType {
  final int id;
  final String name; // 'name' ahora es no nulo
  final bool acceptsMultiple; // 'acceptsMultiple' ahora es no nulo y requerido
  final List<Modifier>? modifiers;

  ModifierType({
    required this.id,
    required this.name, // 'name' es requerido
    required this.acceptsMultiple, // 'acceptsMultiple' es ahora requerido
    this.modifiers,
  });

  factory ModifierType.fromJson(Map<String, dynamic> json) {
    return ModifierType(
      id: json['id'],
      name: json['name']
          as String, // Aseguramos que 'name' sea tratado como String no nulo
      acceptsMultiple: json['acceptsMultiple']
          as bool, // Aseguramos que 'acceptsMultiple' sea tratado como bool no nulo
      modifiers: json['modifiers'] != null
          ? (json['modifiers'] as List)
              .map((i) => Modifier.fromJson(i))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'id': id,
      'name': name, // 'name' es siempre no nulo
      'acceptsMultiple':
          acceptsMultiple, // 'acceptsMultiple' es siempre no nulo
    };
    if (modifiers != null) {
      data['modifiers'] = modifiers!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
