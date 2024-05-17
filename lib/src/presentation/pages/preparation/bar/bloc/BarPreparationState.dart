import 'package:equatable/equatable.dart';
import 'package:restaurante/src/domain/models/Order.dart';

enum OrderFilter { all, delivery, dineIn, pickUpWait }

class BarPreparationState extends Equatable {
  final bool isConnected;
  final List<Order>? orders;
  final Order? updatedOrder;
  final String? errorMessage;

  const BarPreparationState({
    this.isConnected = false,
    this.orders,
    this.updatedOrder,
    this.errorMessage,
  });

  // Constructor de fábrica para crear un estado inicial
  factory BarPreparationState.initial() {
    return BarPreparationState(
      isConnected: false, // Valor inicial para la conexión
      orders: [], // Lista inicial vacía de órdenes
      updatedOrder: null, // No hay órdenes actualizadas inicialmente
      errorMessage: null, // Sin mensaje de error inicialmente
    );
  }

  BarPreparationState copyWith({
    bool? isConnected,
    List<Order>? orders,
    Order? updatedOrder,
    String? errorMessage,
    OrderFilter? filter,
  }) {
    return BarPreparationState(
      isConnected: isConnected ?? this.isConnected,
      orders: orders ?? this.orders,
      updatedOrder: updatedOrder ?? this.updatedOrder,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isConnected, orders, updatedOrder, errorMessage];
}
