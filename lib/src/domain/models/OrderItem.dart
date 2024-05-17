import 'package:restaurante/src/domain/models/OrderItemUpdate.dart';
import 'package:restaurante/src/domain/models/Product.dart';
import 'package:restaurante/src/domain/models/ProductVariant.dart';
import 'package:restaurante/src/domain/models/SelectedModifier.dart';
import 'package:restaurante/src/domain/models/SelectedPizzaFlavor.dart';
import 'package:restaurante/src/domain/models/SelectedPizzaIngredient.dart';
import 'package:restaurante/src/domain/models/SelectedProductObservation.dart';
import 'package:restaurante/src/domain/models/Order.dart' as OrderModel;
import 'package:uuid/uuid.dart';

enum OrderItemStatus { created, in_preparation, prepared }

class OrderItem {
  final int? id;
  final String? tempId;
  OrderItemStatus? status;
  bool? canBePreparedInAdvance;
  bool? isBeingPreparedInAdvance;
  String? comments;
  OrderModel.Order? order;
  Product? product;
  ProductVariant? productVariant;
  List<SelectedModifier>? selectedModifiers;
  List<SelectedProductObservation>? selectedProductObservations;
  List<SelectedPizzaFlavor>? selectedPizzaFlavors;
  List<SelectedPizzaIngredient>? selectedPizzaIngredients;
  double? price;
  List<OrderItemUpdate>? orderItemUpdates;

  OrderItem({
    this.id,
    String? tempId,
    this.status,
    this.canBePreparedInAdvance,
    this.isBeingPreparedInAdvance,
    this.comments,
    this.order,
    this.product,
    this.productVariant,
    this.selectedModifiers,
    this.selectedProductObservations,
    this.selectedPizzaFlavors,
    this.selectedPizzaIngredients,
    this.price,
    this.orderItemUpdates,
  }) : tempId = tempId ?? Uuid().v4();

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      status: json['status'] != null
          ? OrderItemStatus.values
              .firstWhere((e) => e.toString().split(".").last == json['status'])
          : null,
      canBePreparedInAdvance: json['canBePreparedInAdvance'],
      isBeingPreparedInAdvance: json['isBeingPreparedInAdvance'],
      comments: json['comments'],
      // order: json['order'] != null
      //     ? OrderModel.Order.fromJson(json['order'])
      //     : null,
      product:
          json['product'] != null ? Product.fromJson(json['product']) : null,
      productVariant: json['productVariant'] != null
          ? ProductVariant.fromJson(json['productVariant'])
          : null,
      selectedModifiers: json['selectedModifiers'] != null
          ? (json['selectedModifiers'] as List)
              .map((i) => SelectedModifier.fromJson(i))
              .toList()
          : null,
      selectedProductObservations: json['selectedProductObservations'] != null
          ? (json['selectedProductObservations'] as List)
              .map((i) => SelectedProductObservation.fromJson(i))
              .toList()
          : null,
      selectedPizzaFlavors: json['selectedPizzaFlavors'] != null
          ? (json['selectedPizzaFlavors'] as List)
              .map((i) => SelectedPizzaFlavor.fromJson(i))
              .toList()
          : null,
      selectedPizzaIngredients: json['selectedPizzaIngredients'] != null
          ? (json['selectedPizzaIngredients'] as List)
              .map((i) => SelectedPizzaIngredient.fromJson(i))
              .toList()
          : null,
      price: json['price'] != null
          ? double.tryParse(json['price'].toString())
          : null,
      orderItemUpdates: json['orderItemUpdates'] != null
          ? (json['orderItemUpdates'] as List)
              .map((i) => OrderItemUpdate.fromJson(i))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['status'] = status.toString().split(".").last;
    data['canBePreparedInAdvance'] = canBePreparedInAdvance;
    data['isBeingPreparedInAdvance'] = isBeingPreparedInAdvance;
    data['comments'] = comments;
    if (order != null) data['order'] = order!.toJson();
    if (product != null) data['product'] = product!.toJson();
    if (productVariant != null) {
      data['productVariant'] = productVariant!.toJson();
    }
    if (selectedModifiers != null) {
      data['selectedModifiers'] =
          selectedModifiers!.map((v) => v.toJson()).toList();
    }
    if (selectedProductObservations != null) {
      data['selectedProductObservations'] =
          selectedProductObservations!.map((v) => v.toJson()).toList();
    }
    if (selectedPizzaFlavors != null) {
      data['selectedPizzaFlavors'] =
          selectedPizzaFlavors!.map((v) => v.toJson()).toList();
    }
    if (selectedPizzaIngredients != null) {
      data['selectedPizzaIngredients'] =
          selectedPizzaIngredients!.map((v) => v.toJson()).toList();
    }
    if (price != null) {
      data['price'] = price;
    }
    if (orderItemUpdates != null) {
      data['orderItemUpdates'] =
          orderItemUpdates!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  OrderItem copyWith({
    int? id,
    String? tempId,
    OrderItemStatus? status,
    bool? canBePreparedInAdvance,
    bool? isBeingPreparedInAdvance,
    String? comments,
    OrderModel.Order? order,
    Product? product,
    ProductVariant? productVariant,
    List<SelectedModifier>? selectedModifiers,
    List<SelectedProductObservation>? selectedProductObservations,
    List<SelectedPizzaFlavor>? selectedPizzaFlavors,
    List<SelectedPizzaIngredient>? selectedPizzaIngredients,
    double? price,
    List<OrderItemUpdate>? orderItemUpdates,
  }) {
    return OrderItem(
      id: id ?? this.id,
      tempId: tempId ?? this.tempId,
      status: status ?? this.status,
      canBePreparedInAdvance:
          canBePreparedInAdvance ?? this.canBePreparedInAdvance,
      isBeingPreparedInAdvance:
          isBeingPreparedInAdvance ?? this.isBeingPreparedInAdvance,
      comments: comments ?? this.comments,
      order: order ?? this.order,
      product: product ?? this.product,
      productVariant: productVariant ?? this.productVariant,
      selectedModifiers: selectedModifiers ?? this.selectedModifiers,
      selectedProductObservations:
          selectedProductObservations ?? this.selectedProductObservations,
      selectedPizzaFlavors: selectedPizzaFlavors ?? this.selectedPizzaFlavors,
      selectedPizzaIngredients:
          selectedPizzaIngredients ?? this.selectedPizzaIngredients,
      price: price ?? this.price,
      orderItemUpdates: orderItemUpdates ?? this.orderItemUpdates,
    );
  }
}
