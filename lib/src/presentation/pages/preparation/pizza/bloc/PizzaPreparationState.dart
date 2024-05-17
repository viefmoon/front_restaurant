import 'package:restaurante/src/domain/models/OrderItemSummary.dart';
import 'package:equatable/equatable.dart';
import 'package:restaurante/src/domain/models/Order.dart';

enum OrderFilter { all, delivery, dineIn, pickUpWait }

class PizzaPreparationState extends Equatable {
  final bool isConnected;
  final List<Order>? orders;
  final Order? updatedOrder;
  final String? errorMessage;
  final List<OrderItemSummary>? orderItemsSummary;

  const PizzaPreparationState({
    this.isConnected = false,
    this.orders,
    this.updatedOrder,
    this.errorMessage,
    this.orderItemsSummary,
  });

  // Constructor de fábrica para crear un estado inicial
  factory PizzaPreparationState.initial() {
    return PizzaPreparationState(
      isConnected: false, // Valor inicial para la conexión
      orders: [], // Lista inicial vacía de órdenes
      updatedOrder: null, // No hay órdenes actualizadas inicialmente
      errorMessage: null, // Sin mensaje de error inicialmente
      orderItemsSummary: [],
    );
  }

  PizzaPreparationState copyWith({
    bool? isConnected,
    List<Order>? orders,
    Order? updatedOrder,
    String? errorMessage,
    OrderFilter? filter,
    List<OrderItemSummary>? orderItemsSummary,
  }) {
    return PizzaPreparationState(
      isConnected: isConnected ?? this.isConnected,
      orders: orders ?? this.orders,
      updatedOrder: updatedOrder ?? this.updatedOrder,
      errorMessage: errorMessage ?? this.errorMessage,
      orderItemsSummary: orderItemsSummary ?? this.orderItemsSummary,
    );
  }

  @override
  List<Object?> get props => [
        isConnected,
        orders,
        updatedOrder,
        errorMessage,
        orderItemsSummary,
      ];
}
