import 'Area.dart';

enum TableStatus { Disponible, Ocupada }

class Table {
  final int? id; // 'id' ahora es no nulo
  final int? number; // 'number' ahora es nullable
  final TableStatus? status;
  Area? area;
  final String? temporaryIdentifier; // Nueva columna 'temporaryIdentifier'

  Table({
    this.id,
    this.number,
    this.status,
    this.area,
    this.temporaryIdentifier,
  });

  factory Table.fromJson(Map<String, dynamic> json) {
    return Table(
      id: json['id'], // Asumimos que 'id' siempre está presente
      number: json['number'], // 'number' ahora puede ser nulo
      status: json['status'] != null
          ? TableStatus.values.firstWhere(
              (e) => e.toString().split('.').last == json['status'],
              orElse: () => TableStatus.Disponible,
            )
          : null,
      area: json['area'] != null ? Area.fromJson(json['area']) : null,
      temporaryIdentifier: json[
          'temporaryIdentifier'], // Añadido el manejo de 'temporaryIdentifier'
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['number'] = number;
    data['status'] = status?.toString().split('.').last;
    if (area != null) {
      data['area'] = area?.toJson();
    }
    data['temporaryIdentifier'] =
        temporaryIdentifier; // Añadido 'temporaryIdentifier' al JSON
    return data;
  }
}
