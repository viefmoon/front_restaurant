import 'package:restaurante/src/domain/models/Modifier.dart';
import 'package:restaurante/src/domain/models/OrderItem.dart';

class SelectedModifier {
  final int? id;
  final OrderItem? orderItem;
  final Modifier? modifier;

  SelectedModifier({
    this.id,
    this.orderItem,
    this.modifier,
  });

  factory SelectedModifier.fromJson(Map<String, dynamic> json) {
    return SelectedModifier(
      id: json['id'],
      modifier:
          json['modifier'] != null ? Modifier.fromJson(json['modifier']) : null,
      orderItem: json['orderItem'] != null
          ? OrderItem.fromJson(json['orderItem'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    if (modifier != null) {
      data['modifier'] = modifier!.toJson();
    }
    if (orderItem != null) {
      data['orderItem'] = orderItem!.toJson();
    }
    return data;
  }
}
