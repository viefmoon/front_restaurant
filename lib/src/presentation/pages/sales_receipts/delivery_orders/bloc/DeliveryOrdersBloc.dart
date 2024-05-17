import 'package:restaurante/src/domain/models/Order.dart';
import 'package:restaurante/src/domain/useCases/orders/OrdersUseCases.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/delivery_orders/bloc/DeliveryOrdersEvent.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/delivery_orders/bloc/DeliveryOrdersState.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeliveryOrdersBloc
    extends Bloc<DeliveryOrdersEvent, DeliveryOrdersState> {
  final OrdersUseCases ordersUseCases;

  DeliveryOrdersBloc({required this.ordersUseCases})
      : super(DeliveryOrdersState()) {
    on<LoadDeliveryOrders>(_onLoadDeliveryOrders);
    on<MarkOrdersAsInDelivery>(_onMarkOrdersAsInDelivery);
    on<MarkOrdersAsDelivered>(_onMarkOrdersAsDelivered);
    on<RevertOrdersToPrepared>(_onRevertOrdersToPrepared);
  }

  Future<void> _onLoadDeliveryOrders(
      LoadDeliveryOrders event, Emitter<DeliveryOrdersState> emit) async {
    emit(state.copyWith(response: Loading()));
    Resource<List<Order>> response =
        await ordersUseCases.getDeliveryOrders.run();
    if (response is Success<List<Order>>) {
      List<Order> orders = response.data;
      emit(state.copyWith(orders: orders, response: Initial()));
    } else {
      emit(state.copyWith(orders: [], response: Initial()));
    }
  }

  Future<void> _onMarkOrdersAsInDelivery(
      MarkOrdersAsInDelivery event, Emitter<DeliveryOrdersState> emit) async {
    emit(state.copyWith(response: Loading()));
    try {
      await ordersUseCases.markOrdersAsInDelivery.run(event.orders);
      Resource<List<Order>> response =
          await ordersUseCases.getDeliveryOrders.run();
      if (response is Success<List<Order>>) {
        List<Order> orders = response.data;
        emit(state.copyWith(orders: orders, response: Success(orders)));
      } else {
        emit(state.copyWith(
            orders: [],
            response: Error('Error al marcar las órdenes como en reparto')));
      }
    } catch (e) {
      emit(state.copyWith(
          response: Error('Error al marcar las órdenes como en reparto: $e')));
    }
  }

  Future<void> _onMarkOrdersAsDelivered(
      MarkOrdersAsDelivered event, Emitter<DeliveryOrdersState> emit) async {
    emit(state.copyWith(response: Loading()));
    try {
      List<int> orderIds = event.orders.map((order) => order.id!).toList();
      await ordersUseCases.completeMultipleOrders.run(orderIds);
      Resource<List<Order>> response =
          await ordersUseCases.getDeliveryOrders.run();
      if (response is Success<List<Order>>) {
        List<Order> orders = response.data;
        emit(state.copyWith(orders: orders, response: Success(orders)));
      } else {
        emit(state.copyWith(
            orders: [],
            response: Error('Error al marcar las órdenes como entregadas')));
      }
    } catch (e) {
      emit(state.copyWith(
          response: Error('Error al marcar las órdenes como entregadas: $e')));
    }
  }

  Future<void> _onRevertOrdersToPrepared(
      RevertOrdersToPrepared event, Emitter<DeliveryOrdersState> emit) async {
    emit(state.copyWith(response: Loading()));
    try {
      List<int> orderIds = event.orders.map((order) => order.id!).toList();
      await ordersUseCases.revertMultipleOrders.run(orderIds);
      Resource<List<Order>> response =
          await ordersUseCases.getDeliveryOrders.run();
      if (response is Success<List<Order>>) {
        List<Order> orders = response.data;
        emit(state.copyWith(orders: orders, response: Success(orders)));
      } else {
        emit(state.copyWith(
            orders: [],
            response: Error('Error al revertir las órdenes a "Preparado"')));
      }
    } catch (e) {
      emit(state.copyWith(
          response: Error('Error al revertir las órdenes a "Preparado": $e')));
    }
  }
}
