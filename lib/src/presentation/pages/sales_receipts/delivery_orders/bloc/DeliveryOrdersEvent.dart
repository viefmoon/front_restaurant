import 'package:restaurante/src/domain/models/Order.dart';
import 'package:equatable/equatable.dart';

abstract class DeliveryOrdersEvent extends Equatable {
  const DeliveryOrdersEvent();

  @override
  List<Object> get props => [];
}

class LoadDeliveryOrders extends DeliveryOrdersEvent {
  const LoadDeliveryOrders();
}

class MarkOrdersAsInDelivery extends DeliveryOrdersEvent {
  final List<Order> orders;

  const MarkOrdersAsInDelivery(this.orders);

  @override
  List<Object> get props => [orders];
}

class MarkOrdersAsDelivered extends DeliveryOrdersEvent {
  final List<Order> orders;

  const MarkOrdersAsDelivered(this.orders);

  @override
  List<Object> get props => [orders];
}

class RevertOrdersToPrepared extends DeliveryOrdersEvent {
  final List<Order> orders;

  const RevertOrdersToPrepared(this.orders);

  @override
  List<Object> get props => [orders];
}
