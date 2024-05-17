import 'dart:convert';
import 'package:restaurante/src/data/api/ApiConfig.dart';
import 'package:restaurante/src/domain/models/OrderItem.dart';
import 'package:restaurante/src/domain/models/OrderItemSummary.dart';
import 'package:restaurante/src/domain/useCases/orders/OrdersUseCases.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';
import 'package:restaurante/src/presentation/pages/preparation/pizza/bloc/PizzaPreparationEvent.dart';
import 'package:restaurante/src/presentation/pages/preparation/pizza/bloc/PizzaPreparationState.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurante/src/domain/models/Order.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class PizzaPreparationBloc
    extends Bloc<PizzaPreparationEvent, PizzaPreparationState> {
  final OrdersUseCases orderUseCases;
  IO.Socket? socket;

  PizzaPreparationBloc({required this.orderUseCases})
      : super(PizzaPreparationState.initial()) {
    initialize();
  }

  Future<void> initialize() async {
    final ip = await ApiConfig.getApiEcommerce();
    print('ip: $ip');
    socket = IO.io('http://$ip', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'query': {'screenType': 'pizzaScreen'}
    });

    _connectToWebSocket();
    _registerSocketEvents();
    _registerEventHandlers();
  }

  void _connectToWebSocket() {
    socket?.connect();
  }

  void _registerSocketEvents() {
    socket?.on('connect', (_) => print('Connected'));
    socket?.on('disconnect', (_) => print('Disconnected'));
    socket?.on('synchronizationEvent', _handleSocketData);
    socket?.on('orderStatusUpdated', _handleSocketData);
    socket?.on('orderItemStatusUpdated', _handleSocketData);
    socket?.on('orderItemPreparationAdvanceStatusUpdated', _handleSocketData);
    socket?.on('newOrderItems', _handleSocketData);
    socket?.on('orderUpdated', _handleSocketData);
  }

  void _handleSocketData(data) {
    final String dataString = json.encode(data);
    add(WebSocketMessageReceived(dataString));
  }

  void _registerEventHandlers() {
    on<ConnectToWebSocket>(_onConnectToWebSocket);
    on<WebSocketMessageReceived>(_onWebSocketMessageReceived);
    on<OrderPreparationUpdated>(_onOrderPreparationUpdated);
    on<UpdateOrderPreparationStatusEvent>(_onUpdateOrderPreparationStatusEvent);
    on<UpdateOrderItemStatusEvent>(_onUpdateOrderItemStatusEvent);
    on<SynchronizeOrdersEvent>(_onSynchronizeOrdersEvent);
    on<FetchOrderItemsSummaryEvent>(
        _onFetchOrderItemsSummaryEvent); // Nuevo manejador
    on<UpdateOrderItemPreparationAdvanceStatusEvent>(
        _onUpdateOrderItemPreparationAdvanceStatusEvent);
  }

  void _onConnectToWebSocket(
      ConnectToWebSocket event, Emitter<PizzaPreparationState> emit) {
    socket?.connect();
    emit(state.copyWith(isConnected: true));
  }

  void disconnectWebSocket() {
    if (socket?.connected ?? false) {
      socket?.disconnect();
    }
  }

  void _onWebSocketMessageReceived(
      WebSocketMessageReceived event, Emitter<PizzaPreparationState> emit) {
    final data = json.decode(event.message);
    final messageType = data['messageType'];
    switch (messageType) {
      case 'orderItemStatusUpdated':
        _handleOrderItemStatusUpdate(data, emit);
        break;
      case 'orderStatusUpdated':
        _handleOrderStatusUpdate(data, emit);
        break;
      case 'orderItemPreparationAdvanceStatusUpdated':
        _handleOrderItemPreparationAdvanceStatusUpdate(data, emit);
        break;
      case 'newOrderItems':
        _handleNewOrder(data, emit);
        break;
      case 'synchronizationEvent':
        _handleSynchronizationEvent(data, emit);
        break;
      case 'orderUpdated':
        _handleNewOrder(data, emit);
        break;
      default:
    }
  }

  void _handleOrderStatusUpdate(
      Map<String, dynamic> data, Emitter<PizzaPreparationState> emit) {
    final orderId = data['orderId'];
    final newStatus = _parseOrderStatus(data['pizzaPreparationStatus']);
    bool orderExists = false;
    final updatedOrders = state.orders?.map((existingOrder) {
      if (existingOrder.id == orderId) {
        orderExists = true;
        final updatedOrderItems = existingOrder.orderItems?.map((existingItem) {
          final updateInfo = data['orderItems'].firstWhere(
              (item) => item['id'] == existingItem.id,
              orElse: () => null);
          return updateInfo != null
              ? existingItem.copyWith(
                  status: _parseOrderItemStatus(updateInfo['status']))
              : existingItem;
        }).toList();
        return existingOrder.copyWith(
            pizzaPreparationStatus: newStatus, orderItems: updatedOrderItems);
      }
      return existingOrder;
    }).toList();

    if (orderExists && updatedOrders != null) {
      emit(state.copyWith(orders: updatedOrders));
    }
  }

  void _handleOrderItemPreparationAdvanceStatusUpdate(
      Map<String, dynamic> data, Emitter<PizzaPreparationState> emit) {
    print('data aqu: $data');
    final orderId = data['orderId'];
    final orderItemId = data['orderItemId'];
    final isBeingPreparedInAdvance = data['isBeingPreparedInAdvance'];

    final updatedOrders = state.orders?.map((existingOrder) {
      if (existingOrder.id == orderId) {
        final updatedOrderItems = existingOrder.orderItems?.map((existingItem) {
          if (existingItem.id == orderItemId) {
            return existingItem.copyWith(
              isBeingPreparedInAdvance: isBeingPreparedInAdvance,
            );
          }
          return existingItem;
        }).toList();
        return existingOrder.copyWith(orderItems: updatedOrderItems);
      }
      return existingOrder;
    }).toList();

    emit(state.copyWith(orders: updatedOrders));
  }

  void _handleOrderItemStatusUpdate(
      Map<String, dynamic> data, Emitter<PizzaPreparationState> emit) {
    final orderId = data['orderId'];
    final orderItemId = data['orderItemId'];
    final newStatus = _parseOrderItemStatus(data['status']);

    bool orderItemUpdated = false;
    final updatedOrders = state.orders?.map((existingOrder) {
      if (existingOrder.id == orderId) {
        final updatedOrderItems = existingOrder.orderItems?.map((existingItem) {
              if (existingItem.id == orderItemId) {
                orderItemUpdated = true;
                return existingItem.copyWith(status: newStatus);
              }
              return existingItem;
            }).toList() ??
            [];
        return existingOrder.copyWith(orderItems: updatedOrderItems);
      }
      return existingOrder;
    }).toList();

    if (orderItemUpdated && updatedOrders != null) {
      emit(state.copyWith(orders: updatedOrders));
    }
  }

  void _handleNewOrder(
      Map<String, dynamic> data, Emitter<PizzaPreparationState> emit) {
    final order = _parseOrderFromMessage(data);
    List<Order> updatedOrders = List<Order>.from(state.orders ?? []);
    bool orderExists =
        updatedOrders.any((existingOrder) => existingOrder.id == order.id);
    if (!orderExists) {
      updatedOrders.add(order);
    } else {
      updatedOrders = updatedOrders
          .map((existingOrder) =>
              existingOrder.id == order.id ? order : existingOrder)
          .toList();
    }

    emit(state.copyWith(orders: updatedOrders));
  }

  void _handleSynchronizationEvent(
      Map<String, dynamic> data, Emitter<PizzaPreparationState> emit) {
    final ordersData = data['data'] as List<dynamic>? ?? [];
    List<Order> newOrders = ordersData.map((orderData) {
      Order order = Order.fromJson(orderData['order']);
      List<OrderItem> orderItems = (orderData['orderItems'] as List<dynamic>)
          .map((itemData) => OrderItem.fromJson(itemData))
          .toList();
      order.orderItems = orderItems;
      return order;
    }).toList();
    emit(state.copyWith(orders: newOrders));
  }

  void _onOrderPreparationUpdated(
      OrderPreparationUpdated event, Emitter<PizzaPreparationState> emit) {
    final updatedOrders = state.orders
        ?.map((order) =>
            order.id == event.orderUpdate.id ? event.orderUpdate : order)
        .toList();
    emit(state.copyWith(orders: updatedOrders as List<Order>));
  }

  Future<void> _onUpdateOrderPreparationStatusEvent(
      UpdateOrderPreparationStatusEvent event,
      Emitter<PizzaPreparationState> emit) async {
    try {
      Order orderToUpdate = Order(
        id: event.orderId,
        pizzaPreparationStatus: event.newStatus,
      );

      final result = await orderUseCases.updateOrderStatus.run(orderToUpdate);

      if (result is Success<Order>) {
        // Opcional: Emitir un estado de éxito
      } else {
        // Opcional: Manejo de casos de fallo
      }
    } catch (e) {
      emit(state.copyWith(
          errorMessage: "Error actualizando el estado de la orden: $e"));
    }
  }

  Future<void> _onSynchronizeOrdersEvent(
      SynchronizeOrdersEvent event, Emitter<PizzaPreparationState> emit) async {
    try {
      final orders = await orderUseCases.synchronizeData.run();
      emit(state.copyWith(orders: orders));
    } catch (e) {
      emit(
          state.copyWith(errorMessage: "Error al sincronizar los pedidos: $e"));
    }
  }

  Future<void> _onFetchOrderItemsSummaryEvent(
    FetchOrderItemsSummaryEvent event,
    Emitter<PizzaPreparationState> emit,
  ) async {
    try {
      // Asegúrate de que el tipo de retorno aquí sea correcto, es decir, Resource<List<OrderItemSummary>>
      final Resource<List<OrderItemSummary>> result =
          await orderUseCases.findOrderItemsWithCounts.run(
        subcategories: ["Entradas", "Pizzas"],
        ordersLimit: 10,
      );

      // Manejo basado en el tipo de resultado (éxito o error)
      if (result is Success<List<OrderItemSummary>>) {
        // Aquí manejas el caso de éxito
        List<OrderItemSummary> summaries = result.data;
        // Emites un estado con la lista de resmenes obtenida
        emit(state.copyWith(orderItemsSummary: summaries));
      } else if (result is Error) {
        // Aquí manejas el caso de error
        //emit(state.copyWith(errorMessage: result.message));
      }
    } catch (e) {
      // Manejo de errores inesperados
      emit(state.copyWith(
          errorMessage: "Error al obtener el resumen de OrderItems: $e"));
    }
  }

  void _onUpdateOrderItemStatusEvent(UpdateOrderItemStatusEvent event,
      Emitter<PizzaPreparationState> emit) async {
    try {
      final orderItemToUpdate = OrderItem(
          id: event.orderItemId,
          order: Order(id: event.orderId),
          status: event.newStatus);
      final result =
          await orderUseCases.updateOrderItemStatus.run(orderItemToUpdate);
      if (result is Success<OrderItem>) {
        // Opcional: Emitir un estado de éxito
      } else {
        // Opcional: Manejo de casos de fallo
      }
    } catch (e) {
      emit(state.copyWith(
          errorMessage:
              "Error actualizando el estado del item de la orden: $e"));
    }
  }

  void _onUpdateOrderItemPreparationAdvanceStatusEvent(
      UpdateOrderItemPreparationAdvanceStatusEvent event,
      Emitter<PizzaPreparationState> emit) async {
    try {
      final result = await orderUseCases.updateOrderItemPreparationAdvanceStatus
          .run(event.orderId, event.orderItemId, event.newStatus);
      if (result is Success<OrderItem>) {
        // Opcional: Emitir un estado de éxito
      } else {
        // Opcional: Manejo de casos de fallo
      }
    } catch (e) {
      emit(state.copyWith(
          errorMessage:
              "Error actualizando el estado de preparación adelantada del item de la orden: $e"));
    }
  }

  OrderPreparationStatus _parseOrderStatus(String status) {
    return OrderPreparationStatus.values.firstWhere(
      (e) => e.toString().split(".").last == status,
      orElse: () => OrderPreparationStatus.not_required, // Valor por defecto
    );
  }

  OrderItemStatus _parseOrderItemStatus(String status) {
    return OrderItemStatus.values.firstWhere(
      (e) => e.toString().split(".").last == status,
      orElse: () => OrderItemStatus.created, // Valor por defecto
    );
  }

  Order _parseOrderFromMessage(Map<String, dynamic> data) {
    final orderJson = data['order'];
    final orderItemsJson = data['orderItems'] as List<dynamic>;
    var order = Order.fromJson(orderJson);
    order.updateItems(orderItemsJson
        .map((orderItemJson) => OrderItem.fromJson(orderItemJson))
        .toList());
    return order;
  }
}
