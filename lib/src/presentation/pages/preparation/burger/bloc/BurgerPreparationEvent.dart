import 'package:restaurante/src/domain/models/Order.dart';
import 'package:restaurante/src/domain/models/OrderItem.dart';
import 'package:equatable/equatable.dart';

abstract class BurgerPreparationEvent extends Equatable {
  const BurgerPreparationEvent();

  @override
  List<Object> get props => [];
}

class ConnectToWebSocket extends BurgerPreparationEvent {}

class WebSocketMessageReceived extends BurgerPreparationEvent {
  final String message;

  const WebSocketMessageReceived(this.message);

  @override
  List<Object> get props => [message];
}

class OrderPreparationUpdated extends BurgerPreparationEvent {
  final dynamic orderUpdate; // Considera usar un tipo más específico

  const OrderPreparationUpdated(this.orderUpdate);

  @override
  List<Object> get props => [orderUpdate];
}

enum PreparationStatusType {
  barPreparationStatus,
  burgerPreparationStatus,
  pizzaPreparationStatus
}

class UpdateOrderPreparationStatusEvent extends BurgerPreparationEvent {
  final int orderId;
  final OrderPreparationStatus newStatus;
  final PreparationStatusType statusType;

  const UpdateOrderPreparationStatusEvent(
      this.orderId, this.newStatus, this.statusType);

  @override
  List<Object> get props => [orderId, newStatus, statusType];
}

class UpdateOrderItemStatusEvent extends BurgerPreparationEvent {
  final int orderId;
  final int orderItemId;
  final OrderItemStatus newStatus;

  const UpdateOrderItemStatusEvent(
      {required this.orderId,
      required this.orderItemId,
      required this.newStatus});
}

class SynchronizeOrdersEvent extends BurgerPreparationEvent {}
