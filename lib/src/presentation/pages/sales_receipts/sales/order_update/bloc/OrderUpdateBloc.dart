import 'package:restaurante/src/domain/models/Area.dart';
import 'package:restaurante/src/domain/models/AuthResponse.dart';
import 'package:restaurante/src/domain/models/Category.dart';
import 'package:restaurante/src/domain/models/Order.dart';
import 'package:restaurante/src/domain/models/OrderAdjustment.dart';
import 'package:restaurante/src/domain/models/OrderItem.dart';
import 'package:restaurante/src/domain/models/Subcategory.dart';
import 'package:restaurante/src/domain/models/Table.dart' as appModel;
import 'package:restaurante/src/domain/useCases/areas/AreasUseCases.dart';
import 'package:restaurante/src/domain/useCases/auth/AuthUseCases.dart';
import 'package:restaurante/src/domain/useCases/categories/CategoriesUseCases.dart';
import 'package:restaurante/src/domain/useCases/orders/OrdersUseCases.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales/order_update/bloc/OrderUpdateEvent.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales/order_update/bloc/OrderUpdateState.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';

class OrderUpdateBloc extends Bloc<OrderUpdateEvent, OrderUpdateState> {
  final OrdersUseCases ordersUseCases;
  final AreasUseCases areasUseCases;
  final CategoriesUseCases categoriesUseCases;
  final AuthUseCases authUseCases;

  OrderUpdateBloc({
    required this.ordersUseCases,
    required this.areasUseCases,
    required this.categoriesUseCases,
    required this.authUseCases,
  }) : super(OrderUpdateState()) {
    on<LoadOpenOrders>(_onLoadOpenOrders);
    on<OrderTypeSelected>(_onOrderTypeSelected);
    on<PhoneNumberEntered>(_onPhoneNumberEntered);
    on<DeliveryAddressEntered>(_onDeliveryAddressEntered);
    on<CustomerNameEntered>(_onCustomerNameEntered);
    on<OrderCommentsEntered>(_onOrderCommentsEntered);
    on<TimeSelected>(_onTimeSelected);
    on<LoadAreas>(_onLoadAreas);
    on<LoadTables>(_onLoadTables);
    on<AreaSelected>(_onAreaSelected);
    on<TableSelected>(_onTableSelected);
    on<AddOrderItem>(_onAddOrderItem);
    on<UpdateOrderItem>(_onUpdateOrderItem);
    on<OrderSelectedForUpdate>(_onOrderSelectedForUpdate);
    on<ResetOrderUpdateState>(_onResetOrderUpdateState);
    on<RemoveOrderItem>(_onRemoveOrderItem);
    on<LoadCategoriesWithProducts>(_onLoadCategoriesWithProducts);
    on<CategorySelected>(_onCategorySelected);
    on<SubcategorySelected>(_onSubcategorySelected);
    on<UpdateOrder>(_onUpdateOrder);
    on<TimePickerEnabled>(_onTimePickerEnabled);
    on<ResetResponseEvent>(_onResetResponse);
    on<CancelOrder>(_onCancelOrder);
    on<OrderAdjustmentAdded>(_onOrderAdjustmentAdded);
    on<OrderAdjustmentRemoved>(_onOrderAdjustmentRemoved);
    on<OrderAdjustmentUpdated>(_onOrderAdjustmentUpdated);
    on<UpdateTotalCost>(_onUpdateTotalCost);
    on<RegisterPayment>(_onRegisterPayment);
    on<FinishOrder>(_onFinishOrder);
    on<ToggleTemporaryTable>(_onToggleTemporaryTable);
    on<UpdateTemporaryIdentifier>(_onUpdateTemporaryIdentifier);
    on<RegisterTicketPrint>(_onRegisterTicketPrint);
  }

  Future<void> _onResetOrderUpdateState(
      ResetOrderUpdateState event, Emitter<OrderUpdateState> emit) async {
    emit(state.copyWith(
      orders: [],
      orderIdSelectedForUpdate: null,
      selectedOrderType: null,
      areas: [],
      tables: [],
      selectedAreaId: null,
      selectedAreaName: "",
      selectedTableId: null,
      selectedTableNumber: null,
      phoneNumber: "",
      deliveryAddress: "",
      customerName: "",
      comments: "",
      scheduledDeliveryTime: null,
      totalCost: null,
      orderItems: [],
      categories: [],
      selectedCategoryId: null,
      filteredSubcategories: [],
      selectedSubcategoryId: null,
      filteredProducts: [],
      isTimePickerEnabled: false,
      selectedOrder: null,
      isTemporaryTableEnabled: false,
      temporaryIdentifier: "",
    ));
    await _onLoadOpenOrders(LoadOpenOrders(), emit);
  }

  Future<void> _onTimePickerEnabled(
      TimePickerEnabled event, Emitter<OrderUpdateState> emit) async {
    emit(state.copyWith(isTimePickerEnabled: event.isTimePickerEnabled));
    // Si el TimePicker se deshabilita, también resetea el tiempo seleccionado
    if (!event.isTimePickerEnabled) {
      emit(state.copyWith(scheduledDeliveryTime: null));
    }
  }

  Future<void> _onLoadOpenOrders(
      LoadOpenOrders event, Emitter<OrderUpdateState> emit) async {
    emit(state.copyWith(response: Loading()));
    Resource<List<Order>> response = await ordersUseCases.getOpenOrders.run();
    if (response is Success<List<Order>>) {
      List<Order> orders = response.data;
      emit(state.copyWith(orders: orders, response: Initial()));
    } else {
      emit(state.copyWith(orders: [], response: Initial()));
    }
  }

  Future<void> _onOrderSelectedForUpdate(
      OrderSelectedForUpdate event, Emitter<OrderUpdateState> emit) async {
    emit(state.copyWith(
        response:
            Loading())); // Añadir esta línea para manejar el estado de carga

    // Recuperar la orden usando el ID proporcionado
    final Resource<Order> orderResource =
        await ordersUseCases.getOrderForUpdate.run(event.selectedOrder.id!);
    if (orderResource is Success<Order>) {
      final Order order = orderResource.data;

      // Asegrate de convertir la fecha y hora programadas a la zona horaria local antes de crear TimeOfDay
      final DateTime? localScheduledDeliveryTime =
          order.scheduledDeliveryTime?.toLocal();

      emit(state.copyWith(
          selectedOrderType: order.orderType, response: Initial()));

      emit(state.copyWith(
        orderIdSelectedForUpdate: order.id,
        selectedAreaId: order.area?.id,
        selectedTableId: order.table?.temporaryIdentifier == null ||
                order.table!.temporaryIdentifier!.isEmpty
            ? order.table?.id
            : null,
        phoneNumber: order.phoneNumber,
        deliveryAddress: order.deliveryAddress,
        customerName: order.customerName,
        scheduledDeliveryTime: localScheduledDeliveryTime != null
            ? TimeOfDay(
                hour: localScheduledDeliveryTime.hour,
                minute: localScheduledDeliveryTime.minute)
            : null,
        comments: order.comments,
        totalCost: order.totalCost,
        orderItems: order.orderItems,
        isTimePickerEnabled: localScheduledDeliveryTime != null,
        orderAdjustments: order.orderAdjustments,
        selectedOrder: order,
        isTemporaryTableEnabled: order.table?.temporaryIdentifier != null &&
            order.table!.temporaryIdentifier!.isNotEmpty,
        temporaryIdentifier: order.table?.temporaryIdentifier ?? "",
      ));

      // Emitir el evento AreaSelected solo si hay un área seleccionada y el tipo de orden es DineIn
      if (order.orderType == OrderType.dineIn && state.selectedAreaId != null) {
        await _onLoadAreas(LoadAreas(), emit);
        await Future.doWhile(() async {
          await Future.delayed(Duration(milliseconds: 100));
          return state.areas == null || state.areas!.isEmpty;
        });
        // Cargar las mesas después de seleccionar el área y esperar a que estén listas
        await _onLoadTables(LoadTables(areaId: state.selectedAreaId!), emit);
        await Future.doWhile(() async {
          await Future.delayed(Duration(milliseconds: 100));
          return state.tables == null || state.tables!.isEmpty;
        });
        // Solo asignar la mesa si state.tables no es null
        if (state.tables != null) {
          add(TableSelected(tableId: state.selectedTableId!));
        }
      }
    }
  }

  Future<void> _onOrderTypeSelected(
      OrderTypeSelected event, Emitter<OrderUpdateState> emit) async {
    emit(state.copyWith(selectedOrderType: event.selectedOrderType));
    if (event.selectedOrderType == OrderType.dineIn) {
      await _onLoadAreas(LoadAreas(), emit);
      await Future.doWhile(() async {
        await Future.delayed(Duration(milliseconds: 100));
        return state.areas == null || state.areas!.isEmpty;
      });
    }
  }

  Future<void> _onPhoneNumberEntered(
      PhoneNumberEntered event, Emitter<OrderUpdateState> emit) async {
    emit(state.copyWith(phoneNumber: event.phoneNumber));
  }

  Future<void> _onDeliveryAddressEntered(
      DeliveryAddressEntered event, Emitter<OrderUpdateState> emit) async {
    emit(state.copyWith(deliveryAddress: event.deliveryAddress));
  }

  Future<void> _onCustomerNameEntered(
      CustomerNameEntered event, Emitter<OrderUpdateState> emit) async {
    emit(state.copyWith(customerName: event.customerName));
  }

  Future<void> _onOrderCommentsEntered(
      OrderCommentsEntered event, Emitter<OrderUpdateState> emit) async {
    emit(state.copyWith(comments: event.comments));
  }

  Future<void> _onTimeSelected(
      TimeSelected event, Emitter<OrderUpdateState> emit) async {
    emit(state.copyWith(scheduledDeliveryTime: event.time));
  }

  Future<void> _onAreaSelected(
      AreaSelected event, Emitter<OrderUpdateState> emit) async {
    emit(state.copyWith(selectedAreaId: event.areaId, selectedTableId: 0));
    final areaName =
        state.areas?.firstWhere((area) => area.id == event.areaId).name;
    emit(state.copyWith(selectedAreaName: areaName));
    add(LoadTables(areaId: event.areaId));
  }

  Future<void> _onTableSelected(
      TableSelected event, Emitter<OrderUpdateState> emit) async {
    emit(state.copyWith(selectedTableId: event.tableId));
    final tableNumber =
        state.tables?.firstWhere((table) => table.id == event.tableId).number;
    emit(state.copyWith(selectedTableNumber: tableNumber));
  }

  Future<void> _onLoadAreas(
      LoadAreas event, Emitter<OrderUpdateState> emit) async {
    try {
      Resource response = await areasUseCases.getAreas.run();
      if (response is Success<List<Area>>) {
        List<Area> areas = response.data;
        emit(state.copyWith(areas: areas));
      } else {
        emit(state.copyWith(areas: []));
      }
    } catch (e) {
      emit(state.copyWith(areas: []));
    }
  }

  Future<void> _onLoadTables(
      LoadTables event, Emitter<OrderUpdateState> emit) async {
    try {
      Resource response =
          await areasUseCases.getTablesFromArea.run(event.areaId);
      if (response is Success<List<appModel.Table>>) {
        List<appModel.Table> tables = response.data;
        emit(state.copyWith(tables: tables));
      } else {
        emit(state.copyWith(tables: []));
      }
    } catch (e) {
      emit(state.copyWith(tables: []));
    }
  }

  Future<void> _onAddOrderItem(
      AddOrderItem event, Emitter<OrderUpdateState> emit) async {
    final updatedOrderItems = List<OrderItem>.from(state.orderItems ?? [])
      ..add(event.orderItem);
    emit(state.copyWith(orderItems: updatedOrderItems));
  }

  Future<void> _onUpdateOrderItem(
      UpdateOrderItem event, Emitter<OrderUpdateState> emit) async {
    final updatedOrderItems = state.orderItems?.map((orderItem) {
          return orderItem.tempId == event.orderItem.tempId
              ? event.orderItem
              : orderItem;
        }).toList() ??
        [];
    emit(state.copyWith(orderItems: updatedOrderItems));
  }

  Future<void> _onRemoveOrderItem(
      RemoveOrderItem event, Emitter<OrderUpdateState> emit) async {
    final updatedOrderItems = state.orderItems
            ?.where((item) => item.tempId != event.tempId)
            .toList() ??
        [];
    emit(state.copyWith(orderItems: updatedOrderItems));
  }

  Future<void> _onLoadCategoriesWithProducts(
      LoadCategoriesWithProducts event, Emitter<OrderUpdateState> emit) async {
    emit(state.copyWith(response: Loading()));
    try {
      Resource response =
          await categoriesUseCases.getCategoriesWithProducts.run();
      if (response is Success<List<Category>>) {
        List<Category> categories = response.data;
        emit(state.copyWith(categories: categories, response: Initial()));
      } else {
        emit(state.copyWith(categories: [], response: Initial()));
      }
    } catch (e) {
      emit(state.copyWith(categories: []));
    }
  }

  Future<void> _onCategorySelected(
      CategorySelected event, Emitter<OrderUpdateState> emit) async {
    Category? selectedCategory;
    try {
      selectedCategory =
          state.categories?.firstWhere((cat) => cat.id == event.categoryId);
    } catch (e) {
      // If no match is found, selectedCategory remains null.
    }

    final filteredSubcategories = selectedCategory?.subcategories ?? [];

    emit(state.copyWith(
      selectedCategoryId: event.categoryId,
      filteredSubcategories: filteredSubcategories,
      filteredProducts: [],
      selectedSubcategoryId: null,
    ));
  }

  Future<void> _onSubcategorySelected(
      SubcategorySelected event, Emitter<OrderUpdateState> emit) async {
    Subcategory? selectedSubcategory;
    try {
      selectedSubcategory = state.filteredSubcategories
          ?.firstWhere((sub) => sub.id == event.subcategoryId);
    } catch (e) {
      // If no match is found, selectedSubcategory remains null.
    }
    final filteredProducts = selectedSubcategory?.products ?? [];

    emit(state.copyWith(
      selectedSubcategoryId: event.subcategoryId,
      filteredProducts: filteredProducts,
    ));
  }

  Future<void> _onUpdateOrder(
      UpdateOrder event, Emitter<OrderUpdateState> emit) async {
    DateTime? scheduledDeliveryDateTime;
    if (state.isTimePickerEnabled == true &&
        state.scheduledDeliveryTime != null) {
      final now = DateTime.now();
      scheduledDeliveryDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        state.scheduledDeliveryTime!.hour,
        state.scheduledDeliveryTime!.minute,
      );
    }

    // Calcula el totalCost antes de crear la orden
    double totalCost = 0;

    // Calcula el total de los OrderItems
    for (var orderItem in state.orderItems ?? []) {
      totalCost += orderItem.price ?? 0;
    }

    // Calcula el total de los OrderAdjustments
    for (var orderAdjustment in state.orderAdjustments ?? []) {
      totalCost += orderAdjustment.amount ?? 0;
    }

    // Actualiza el estado con el totalCost calculado
    emit(state.copyWith(totalCost: totalCost));

    // Inicializa los campos comunes para todos los tipos de orden
    // Inicializa los campos comunes para todos los tipos de orden
    Order order = Order(
      id: state.orderIdSelectedForUpdate,
      orderType: state.selectedOrderType,
      status: OrderStatus.created,
      totalCost: state.totalCost,
      comments: state.comments,
      creationDate: DateTime.now(),
      scheduledDeliveryTime: scheduledDeliveryDateTime,
      // Inicializa los campos opcionales como null
      phoneNumber: null,
      deliveryAddress: null,
      customerName: null,
      area: null,
      table: null,
      orderItems: state.orderItems,
      orderAdjustments: state.orderAdjustments,
    );

    // Asigna los campos específicos según el tipo de orden
    switch (state.selectedOrderType) {
      case OrderType.dineIn:
        if (state.isTemporaryTableEnabled &&
            (state.temporaryIdentifier?.isNotEmpty ?? false)) {
          final newTable = appModel.Table(
            id: null,
            number: null,
            temporaryIdentifier: state.temporaryIdentifier!,
            status: appModel.TableStatus.Ocupada,
          );
          order = order.copyWith(
            area: state.areas
                ?.firstWhereOrNull((area) => area.id == state.selectedAreaId),
            table: newTable,
          );
        } else {
          order = order.copyWith(
            area: state.areas
                ?.firstWhereOrNull((area) => area.id == state.selectedAreaId),
            table: state.tables?.firstWhereOrNull(
                (table) => table.id == state.selectedTableId),
          );
        }
        break;
      case OrderType.delivery:
        order = order.copyWith(
          phoneNumber: state.phoneNumber,
          deliveryAddress: state.deliveryAddress,
        );
        break;
      case OrderType.pickUpWait:
        order = order.copyWith(
          phoneNumber: state.phoneNumber,
          customerName: state.customerName,
        );
        break;
      default:
        break; // No se requiere acción adicional para otros tipos
    }

    Resource result = await ordersUseCases.updateOrder.run(order);
    if (result is Success<Order>) {
      emit(state.copyWith(response: Success(result)));
    } else if (result is Error<Order>) {
      emit(state.copyWith(response: Error(result.message)));
    }
  }

  Future<void> _onResetResponse(
      ResetResponseEvent event, Emitter<OrderUpdateState> emit) async {
    emit(state.copyWith(response: Initial()));
  }

  Future<void> _onCancelOrder(
      CancelOrder event, Emitter<OrderUpdateState> emit) async {
    if (state.orderIdSelectedForUpdate != null) {
      Resource result =
          await ordersUseCases.cancelOrder.run(state.orderIdSelectedForUpdate!);
      if (result is Success<Order>) {
        emit(state.copyWith(response: Success(result)));
      } else if (result is Error<Order>) {
        emit(state.copyWith(response: Error(result.message)));
      }
    }
  }

  Future<void> _onOrderAdjustmentAdded(
      OrderAdjustmentAdded event, Emitter<OrderUpdateState> emit) async {
    final uuid = Uuid();
    final orderAdjustment = event.orderAdjustment.copyWith(uuid: uuid.v4());
    List<OrderAdjustment> updatedOrderAdjustments =
        List.from(state.orderAdjustments ?? []);
    updatedOrderAdjustments.add(orderAdjustment);
    emit(state.copyWith(orderAdjustments: updatedOrderAdjustments));
  }

  Future<void> _onOrderAdjustmentRemoved(
      OrderAdjustmentRemoved event, Emitter<OrderUpdateState> emit) async {
    List<OrderAdjustment> updatedOrderAdjustments =
        List.from(state.orderAdjustments ?? []);

    // Eliminar el ajuste específico en función de su ID o UUID
    updatedOrderAdjustments.removeWhere((adjustment) =>
        (adjustment.id != null &&
            event.orderAdjustment.id != null &&
            adjustment.id == event.orderAdjustment.id) ||
        (adjustment.uuid != null &&
            event.orderAdjustment.uuid != null &&
            adjustment.uuid == event.orderAdjustment.uuid));

    emit(state.copyWith(orderAdjustments: updatedOrderAdjustments));
  }

  Future<void> _onOrderAdjustmentUpdated(
      OrderAdjustmentUpdated event, Emitter<OrderUpdateState> emit) async {
    List<OrderAdjustment> updatedOrderAdjustments =
        List.from(state.orderAdjustments ?? []);

    if (event.orderAdjustment.id != null) {
      // Si el ajuste tiene un ID, actualiza el ajuste correspondiente en la lista
      int index = updatedOrderAdjustments.indexWhere(
          (adjustment) => adjustment.id == event.orderAdjustment.id);
      if (index != -1) {
        updatedOrderAdjustments[index] = event.orderAdjustment;
      }
    } else {
      // Si el ajuste no tiene un ID, genera un nuevo UUID y agrega el ajuste a la lista
      final uuid = Uuid();
      final orderAdjustment = event.orderAdjustment.copyWith(uuid: uuid.v4());
      updatedOrderAdjustments.add(orderAdjustment);
    }

    emit(state.copyWith(orderAdjustments: updatedOrderAdjustments));
  }

  Future<void> _onUpdateTotalCost(
      UpdateTotalCost event, Emitter<OrderUpdateState> emit) async {
    double totalCost = 0;

    // Calcula el total de los OrderItems
    for (var orderItem in state.orderItems ?? []) {
      totalCost += orderItem.price ?? 0;
    }

    // Calcula el total de los OrderAdjustments
    for (var orderAdjustment in state.orderAdjustments ?? []) {
      totalCost += orderAdjustment.amount ?? 0;
    }

    emit(state.copyWith(totalCost: totalCost));
  }

  Future<void> _onRegisterPayment(
      RegisterPayment event, Emitter<OrderUpdateState> emit) async {
    final Resource result =
        await ordersUseCases.registerPayment.run(event.orderId, event.amount);

    if (result is Success) {
      // Suponiendo que el resultado exitoso incluye la orden actualizada
      //emit(state.copyWith(response: Success(result.data)));
      // Emitir el evento OrderSelectedForUpdate después de registrar el pago
      add(OrderSelectedForUpdate(state.selectedOrder!));
    } else if (result is Error) {
      //emit(state.copyWith(response: Error(result.message)));
    }
  }

  Future<void> _onFinishOrder(
      FinishOrder event, Emitter<OrderUpdateState> emit) async {
    emit(state.copyWith(response: Loading()));

    // Aquí iría la lógica para marcar la orden como finalizada
    final Resource result =
        await ordersUseCases.completeOrder.run(event.orderId);

    if (result is Success) {
      // Suponiendo que el resultado exitoso incluye la orden actualizada
      emit(state.copyWith(response: Success(result.data)));
    } else if (result is Error) {
      emit(state.copyWith(response: Error(result.message)));
    }
  }

  Future<void> _onToggleTemporaryTable(
      ToggleTemporaryTable event, Emitter<OrderUpdateState> emit) async {
    emit(state.copyWith(isTemporaryTableEnabled: event.isEnabled));

    // Si se activa la mesa temporal, resetea la selección de mesa
    if (event.isEnabled) {
      emit(state.copyWith(
        temporaryIdentifier: "",
        selectedTableId: 0,
        selectedTableNumber: 0,
      ));
    } else {
      // Si se desactiva la mesa temporal, limpia el identificador temporal
      emit(state.copyWith(
        temporaryIdentifier: "",
        selectedTableId: 0,
        selectedTableNumber: 0,
      ));
    }
  }

  Future<void> _onUpdateTemporaryIdentifier(
      UpdateTemporaryIdentifier event, Emitter<OrderUpdateState> emit) async {
    emit(state.copyWith(temporaryIdentifier: event.identifier));
  }

  Future<void> _onRegisterTicketPrint(
      RegisterTicketPrint event, Emitter<OrderUpdateState> emit) async {
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
