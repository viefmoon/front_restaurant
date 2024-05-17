import 'package:equatable/equatable.dart';

abstract class PendingOrderItemsEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadPendingOrderItems extends PendingOrderItemsEvent {}

class RefreshPendingOrderItems extends PendingOrderItemsEvent {}
