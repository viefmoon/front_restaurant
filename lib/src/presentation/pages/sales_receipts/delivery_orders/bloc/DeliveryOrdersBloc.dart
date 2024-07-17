import 'package:restaurante/src/domain/models/AuthResponse.dart';
import 'package:restaurante/src/domain/models/Order.dart';
import 'package:restaurante/src/domain/useCases/auth/AuthUseCases.dart';
import 'package:restaurante/src/domain/useCases/orders/OrdersUseCases.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/delivery_orders/bloc/DeliveryOrdersEvent.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/delivery_orders/bloc/DeliveryOrdersState.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeliveryOrdersBloc
    extends Bloc<DeliveryOrdersEvent, DeliveryOrdersState> {
  final OrdersUseCases ordersUseCases;
  final AuthUseCases authUseCases;

  DeliveryOrdersBloc({
    required this.ordersUseCases,
    required this.authUseCases,
  }) : super(DeliveryOrdersState()) {
    on<LoadDeliveryOrders>(_onLoadDeliveryOrders);
    on<MarkOrdersAsInDelivery>(_onMarkOrdersAsInDelivery);
    on<MarkOrdersAsDelivered>(_onMarkOrdersAsDelivered);
    on<RevertOrdersToPrepared>(_onRevertOrdersToPrepared);
    on<RegisterTicketPrint>(_onRegisterTicketPrint);
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

  Future<void> _onRegisterTicketPrint(
      RegisterTicketPrint event, Emitter<DeliveryOrdersState> emit) async {
    emit(state.copyWith(response: Loading()));

    // Obtener el nombre de usuario
    AuthResponse? userSession = await authUseCases.getUserSession.run();
    String? printedBy = userSession?.user.name;

    final Resource result = await ordersUseCases.registerTicketPrint
        .run(event.orderId, printedBy ?? '');

    if (result is Success) {
      emit(state.copyWith(response: Success(result.data)));
    } else if (result is Error) {
      emit(state.copyWith(response: Error(result.message)));
    }
  }
}
