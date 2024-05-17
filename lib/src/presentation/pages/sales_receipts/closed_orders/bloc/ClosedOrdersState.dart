import 'package:restaurante/src/domain/models/Order.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';
import 'package:equatable/equatable.dart';

class ClosedOrdersState extends Equatable {
  final List<Order>? orders;
  final Resource? response;

  const ClosedOrdersState({
    this.orders,
    this.response,
  });

  ClosedOrdersState copyWith({
    List<Order>? orders,
    Resource? response,
  }) {
    return ClosedOrdersState(
      orders: orders ?? this.orders,
      response: response ?? this.response,
    );
  }

  @override
  List<Object?> get props => [orders, response];
}
