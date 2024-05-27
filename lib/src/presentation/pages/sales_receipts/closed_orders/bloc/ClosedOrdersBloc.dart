import 'package:restaurante/src/domain/models/Order.dart';
import 'package:restaurante/src/domain/useCases/orders/OrdersUseCases.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/closed_orders/bloc/ClosedOrdersEvent.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/closed_orders/bloc/ClosedOrdersState.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClosedOrdersBloc extends Bloc<ClosedOrdersEvent, ClosedOrdersState> {
  final OrdersUseCases ordersUseCases;

  ClosedOrdersBloc({
    required this.ordersUseCases,
  }) : super(ClosedOrdersState()) {
    on<LoadClosedOrders>(_onLoadClosedOrders);
    on<RecoverOrder>(_onRecoverOrder);
  }

  Future<void> _onLoadClosedOrders(
      LoadClosedOrders event, Emitter<ClosedOrdersState> emit) async {
    emit(state.copyWith(response: Loading()));
    Resource<List<Order>> response = await ordersUseCases.getClosedOrders.run();
    if (response is Success<List<Order>>) {
      List<Order> orders = response.data;
      emit(state.copyWith(orders: orders, response: Initial()));
    } else {
      emit(state.copyWith(orders: [], response: Initial()));
    }
  }

  Future<void> _onRecoverOrder(
      RecoverOrder event, Emitter<ClosedOrdersState> emit) async {
    emit(state.copyWith(response: Loading()));
    Resource<Order> response =
        await ordersUseCases.recoverOrder.run(event.orderId);
    if (response is Success<Order>) {
      Order recoveredOrder = response.data;
      // Actualizar la lista de órdenes cerradas en el estado
      List<Order> updatedOrders = state.orders!.map((order) {
        return order.id == recoveredOrder.id ? recoveredOrder : order;
      }).toList();
      emit(state.copyWith(orders: updatedOrders, response: Initial()));
      // Cargar la lista de órdenes cerradas después de recuperar una orden
      add(LoadClosedOrders());
    } else {
      emit(state.copyWith(response: Error((response as Error).message)));
    }
  }
}
