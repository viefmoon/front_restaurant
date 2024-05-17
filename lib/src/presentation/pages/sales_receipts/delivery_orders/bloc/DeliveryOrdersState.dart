import 'package:restaurante/src/domain/models/Order.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';
import 'package:equatable/equatable.dart';

class DeliveryOrdersState extends Equatable {
  final List<Order>? orders;
  final Resource? response;

  const DeliveryOrdersState({
    this.orders,
    this.response,
  });

  DeliveryOrdersState copyWith({
    List<Order>? orders,
    Resource? response,
  }) {
    return DeliveryOrdersState(
      orders: orders ?? this.orders,
      response: response ?? this.response,
    );
  }

  @override
  List<Object?> get props => [orders, response];
}
