import 'package:restaurante/src/domain/models/OrderItemSummary.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales/pending_order_items/bloc/PendingOrderItemsEvent.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales/pending_order_items/bloc/PendingOrderItemsState.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurante/src/domain/useCases/orders/OrdersUseCases.dart';

class PendingOrderItemsBloc
    extends Bloc<PendingOrderItemsEvent, PendingOrderItemsState> {
  final OrdersUseCases ordersUseCases;

  PendingOrderItemsBloc({required this.ordersUseCases})
      : super(PendingOrderItemsInitial()) {
    on<LoadPendingOrderItems>(_onLoadPendingOrderItems);
    on<RefreshPendingOrderItems>(_onRefreshPendingOrderItems);
  }

  Future<void> _onLoadPendingOrderItems(
      LoadPendingOrderItems event, Emitter<PendingOrderItemsState> emit) async {
    emit(PendingOrderItemsLoading());
    try {
      final Resource<List<OrderItemSummary>> result =
          await ordersUseCases.findOrderItemsWithCounts.run(subcategories: [
        "Entradas",
        "Pizzas",
        "Hamburguesas",
        "Ensaladas",
        "Frappes y Malteadas",
        "Jarras",
        "Cocteleria",
        "Bebidas",
        "Cafe Caliente"
      ], ordersLimit: 1000); //sin limite
      if (result is Success<List<OrderItemSummary>>) {
        emit(PendingOrderItemsLoaded(items: result.data));
      } else if (result is Error) {
        emit(PendingOrderItemsError(message: (result as Error).message));
      }
    } catch (error) {
      emit(PendingOrderItemsError(message: error.toString()));
    }
  }

  Future<void> _onRefreshPendingOrderItems(RefreshPendingOrderItems event,
      Emitter<PendingOrderItemsState> emit) async {
    add(LoadPendingOrderItems());
  }
}
