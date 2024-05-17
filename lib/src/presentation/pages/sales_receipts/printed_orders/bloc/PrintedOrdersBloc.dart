import 'package:restaurante/src/domain/models/Order.dart';
import 'package:restaurante/src/domain/useCases/orders/OrdersUseCases.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/printed_orders/bloc/PrintedOrdersEvent.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/printed_orders/bloc/PrintedOrdersState.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PrintedOrdersBloc extends Bloc<PrintedOrdersEvent, PrintedOrdersState> {
  final OrdersUseCases ordersUseCases;

  PrintedOrdersBloc({required this.ordersUseCases})
      : super(PrintedOrdersState()) {
    on<LoadPrintedOrders>(_onLoadPrintedOrders);
    on<MarkOrdersAsPaid>(_onMarkOrdersAsPaid);
  }

  Future<void> _onLoadPrintedOrders(
      LoadPrintedOrders event, Emitter<PrintedOrdersState> emit) async {
    emit(state.copyWith(response: Loading()));
    Resource<List<Order>> response =
        await ordersUseCases.getPrintedOrders.run();
    if (response is Success<List<Order>>) {
      List<Order> orders = response.data;
      emit(state.copyWith(orders: orders, response: Initial()));
    } else {
      emit(state.copyWith(orders: [], response: Initial()));
    }
  }

  Future<void> _onMarkOrdersAsPaid(
      MarkOrdersAsPaid event, Emitter<PrintedOrdersState> emit) async {
    emit(state.copyWith(response: Loading()));
    List<int> orderIds = event.orders.map((order) => order.id!).toList();
    Resource<List<Order>> response =
        await ordersUseCases.completeMultipleOrders.run(orderIds);

    if (response is Success<List<Order>>) {
      List<Order> updatedOrders = response.data;
      emit(state.copyWith(
          orders: updatedOrders, response: Success(updatedOrders)));
      await _onLoadPrintedOrders(LoadPrintedOrders(), emit);
    } else if (response is Error) {
      Error errorResponse = response as Error;
      emit(state.copyWith(response: Error(errorResponse.message)));
      await _onLoadPrintedOrders(LoadPrintedOrders(), emit);
    }
  }
}
