import 'package:equatable/equatable.dart';
import 'package:restaurante/src/domain/models/Order.dart';

enum OrderFilter { all, delivery, dineIn, pickUpWait }

class BurgerPreparationState extends Equatable {
  final bool isConnected;
  final List<Order>? orders;
  final Order? updatedOrder;
  final String? errorMessage;

  BurgerPreparationState({
    this.isConnected = false,
    this.orders,
    this.updatedOrder,
    this.errorMessage,
  });

  // Constructor de fábrica para crear un estado inicial
  factory BurgerPreparationState.initial() {
    return BurgerPreparationState(
      isConnected: false, // Valor inicial para la conexión
      orders: [], // Lista inicial vacía de órdenes
      updatedOrder: null, // No hay órdenes actualizadas inicialmente
      errorMessage: null, // Sin mensaje de error inicialmente
    );
  }

  BurgerPreparationState copyWith({
    bool? isConnected,
    List<Order>? orders,
    Order? updatedOrder,
    String? errorMessage,
    OrderFilter? filter,
  }) {
    return BurgerPreparationState(
      isConnected: isConnected ?? this.isConnected,
      orders: orders ?? this.orders,
      updatedOrder: updatedOrder ?? this.updatedOrder,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isConnected, orders, updatedOrder, errorMessage];
}
