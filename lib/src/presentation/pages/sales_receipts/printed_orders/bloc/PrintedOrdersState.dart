import 'package:restaurante/src/domain/models/Order.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';
import 'package:equatable/equatable.dart';

class PrintedOrdersState extends Equatable {
  final List<Order>? orders;
  final Resource? response;

  PrintedOrdersState({
    this.orders,
    this.response,
  });

  PrintedOrdersState copyWith({
    List<Order>? orders,
    Resource? response,
  }) {
    return PrintedOrdersState(
      orders: orders ?? this.orders,
      response: response ?? this.response,
    );
  }

  @override
  List<Object?> get props => [orders, response];
}
