import 'package:equatable/equatable.dart';
import 'package:restaurante/src/domain/models/OrderItemSummary.dart';

abstract class PendingOrderItemsState extends Equatable {
  @override
  List<Object> get props => [];
}

class PendingOrderItemsInitial extends PendingOrderItemsState {}

class PendingOrderItemsLoading extends PendingOrderItemsState {}

class PendingOrderItemsLoaded extends PendingOrderItemsState {
  final List<OrderItemSummary> items;

  PendingOrderItemsLoaded({required this.items});

  @override
  List<Object> get props => [items];
}

class PendingOrderItemsError extends PendingOrderItemsState {
  final String message;

  PendingOrderItemsError({required this.message});

  @override
  List<Object> get props => [message];
}
