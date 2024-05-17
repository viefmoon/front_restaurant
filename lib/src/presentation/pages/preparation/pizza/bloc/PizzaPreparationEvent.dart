import 'package:restaurante/src/domain/models/Order.dart';
import 'package:restaurante/src/domain/models/OrderItem.dart';
import 'package:equatable/equatable.dart';

abstract class PizzaPreparationEvent extends Equatable {
  const PizzaPreparationEvent();

  @override
  List<Object> get props => [];
}

class ConnectToWebSocket extends PizzaPreparationEvent {}

class WebSocketMessageReceived extends PizzaPreparationEvent {
  final String message;

  const WebSocketMessageReceived(this.message);

  @override
  List<Object> get props => [message];
}

class OrderPreparationUpdated extends PizzaPreparationEvent {
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

class UpdateOrderPreparationStatusEvent extends PizzaPreparationEvent {
  final int orderId;
  final OrderPreparationStatus newStatus;
  final PreparationStatusType statusType;

  const UpdateOrderPreparationStatusEvent(
      this.orderId, this.newStatus, this.statusType);

  @override
  List<Object> get props => [orderId, newStatus, statusType];
}

class UpdateOrderItemStatusEvent extends PizzaPreparationEvent {
  final int orderId;
  final int orderItemId;
  final OrderItemStatus newStatus;

  const UpdateOrderItemStatusEvent(
      {required this.orderId,
      required this.orderItemId,
      required this.newStatus});
}

class SynchronizeOrdersEvent extends PizzaPreparationEvent {}

class FetchOrderItemsSummaryEvent extends PizzaPreparationEvent {
  final List<String>? subcategories;
  final int? ordersLimit;

  const FetchOrderItemsSummaryEvent({this.subcategories, this.ordersLimit});

  @override
  List<Object> get props => [subcategories ?? [], ordersLimit ?? 0];
}

class UpdateOrderItemPreparationAdvanceStatusEvent
    extends PizzaPreparationEvent {
  final int orderId;
  final int orderItemId;
  final bool newStatus;

  const UpdateOrderItemPreparationAdvanceStatusEvent(
      this.orderId, this.orderItemId, this.newStatus);

  @override
  List<Object> get props => [orderId, orderItemId, newStatus];
}
