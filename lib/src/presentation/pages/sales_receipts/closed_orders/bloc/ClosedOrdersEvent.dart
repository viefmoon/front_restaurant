import 'package:equatable/equatable.dart';

abstract class ClosedOrdersEvent extends Equatable {
  const ClosedOrdersEvent();

  @override
  List<Object> get props => [];
}

class LoadClosedOrders extends ClosedOrdersEvent {
  const LoadClosedOrders();
}

class RecoverOrder extends ClosedOrdersEvent {
  final int orderId;

  const RecoverOrder(this.orderId);

  @override
  List<Object> get props => [orderId];
}
