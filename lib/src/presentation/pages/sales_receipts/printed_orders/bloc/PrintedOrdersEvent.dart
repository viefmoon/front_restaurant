import 'package:restaurante/src/domain/models/Order.dart';
import 'package:equatable/equatable.dart';

abstract class PrintedOrdersEvent extends Equatable {
  const PrintedOrdersEvent();

  @override
  List<Object> get props => [];
}

class LoadPrintedOrders extends PrintedOrdersEvent {
  const LoadPrintedOrders();
}

class MarkOrdersAsPaid extends PrintedOrdersEvent {
  final List<Order> orders;

  const MarkOrdersAsPaid(this.orders);

  @override
  List<Object> get props => [orders];
}
