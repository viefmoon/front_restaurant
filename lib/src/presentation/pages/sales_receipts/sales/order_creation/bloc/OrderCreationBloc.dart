import 'package:restaurante/src/domain/models/AuthResponse.dart';
import 'package:restaurante/src/domain/models/Category.dart';
import 'package:restaurante/src/domain/models/Order.dart';
import 'package:restaurante/src/domain/models/OrderAdjustment.dart';
import 'package:restaurante/src/domain/models/OrderItem.dart';
import 'package:restaurante/src/domain/models/Subcategory.dart';
import 'package:restaurante/src/domain/useCases/auth/AuthUseCases.dart';
import 'package:restaurante/src/domain/useCases/categories/CategoriesUseCases.dart';
import 'package:restaurante/src/domain/useCases/orders/OrdersUseCases.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales/order_creation/bloc/OrderCreationEvent.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales/order_creation/bloc/OrderCreationState.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurante/src/domain/useCases/areas/AreasUseCases.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';
import 'package:restaurante/src/domain/models/Area.dart';
import 'package:restaurante/src/domain/models/Table.dart' as appModel;
import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';

class OrderCreationBloc extends Bloc<OrderCreationEvent, OrderCreationState> {
  final AreasUseCases areasUseCases;
  final CategoriesUseCases categoriesUseCases;
  final OrdersUseCases ordersUseCases;
  final AuthUseCases authUseCases;

  OrderCreationBloc(
      {required this.categoriesUseCases,
      required this.areasUseCases,
      required this.ordersUseCases,
      required this.authUseCases})
      : super(OrderCreationState()) {
    on<OrderTypeSelected>(_onOrderTypeSelected);
    on<PhoneNumberEntered>(_onPhoneNumberEntered);
    on<DeliveryAddressEntered>(_onDeliveryAddressEntered);
    on<CustomerNameEntered>(_onCustomerNameEntered);
    on<OrderCommentsEntered>(_onOrderCommentsEntered);
    on<TimeSelected>(_onTimeSelected);
    on<AreaSelected>(_onAreaSelected);
    on<TableSelected>(_onTableSelected);
    on<LoadAreas>(_onLoadAreas);
    on<LoadTables>(_onLoadTables);
    on<TableSelectionContinue>(_onTableSelectionContinue);
    on<LoadCategoriesWithProducts>(_onLoadCategoriesWithProducts);
    on<CategorySelected>(_onCategorySelected);
    on<SubcategorySelected>(_onSubcategorySelected);
    on<AddOrderItem>(_onAddOrderItem);
    on<UpdateOrderItem>(_onUpdateOrderItem);
    on<ResetTableSelection>(_onResetTableSelection);
    on<SendOrder>(_onSendOrder);
    on<ResetOrder>(_onResetOrder);
    on<RemoveOrderItem>(_onRemoveOrderItem);
    on<TimePickerEnabled>(_onTimePickerEnabled);
    on<ResetResponseEvent>(_onResetResponse);
    on<OrderAdjustmentAdded>(_onOrderAdjustmentAdded);
    on<OrderAdjustmentRemoved>(_onOrderAdjustmentRemoved);
    on<OrderAdjustmentUpdated>(_onOrderAdjustmentUpdated);
    on<UpdateTotalCost>(_onUpdateTotalCost);
    on<ToggleTemporaryTable>(_onToggleTemporaryTable);
    on<UpdateTemporaryIdentifier>(_onUpdateTemporaryIdentifier);
  }

  Future<void> _onResetOrder(
      ResetOrder event, Emitter<OrderCreationState> emit) async {
    emit(OrderCreationState(
      selectedOrderType: null,
      phoneNumber: null,
      areas: const [],
      tables: const [],
      selectedAreaId: null,
      selectedAreaName: null,
      selectedTableId: null,
      selectedTableNumber: null,
      categories: const [],
      selectedCategoryId: null,
      selectedSubcategoryId: null,
      filteredSubcategories: const [],
      filteredProducts: const [],
      orderItems: const [],
      deliveryAddress: null,
      customerName: null,
      comments: null,
      scheduledDeliveryTime: null,
      totalCost: null,
      response: null,
      step: OrderCreationStep.orderTypeSelection,
      isTimePickerEnabled: false,
      isTemporaryTableEnabled: false,
      temporaryIdentifier: "",
    ));
    await _onLoadAreas(LoadAreas(), emit);
  }

  Future<void> _onTimePickerEnabled(
      TimePickerEnabled event, Emitter<OrderCreationState> emit) async {
    emit(state.copyWith(isTimePickerEnabled: event.isTimePickerEnabled));
    // Si el TimePicker se deshabilita, también resetea el tiempo seleccionado
    if (!event.isTimePickerEnabled) {
      emit(state.copyWith(scheduledDeliveryTime: null));
    }
  }

  Future<void> _onOrderTypeSelected(
      OrderTypeSelected event, Emitter<OrderCreationState> emit) async {
    OrderCreationStep nextStep;
    switch (event.selectedOrderType) {
      case OrderType.delivery:
        nextStep = OrderCreationStep.phoneNumberInput;
        break;
      case OrderType.dineIn:
        nextStep = OrderCreationStep.tableSelection;
        break;
      case OrderType.pickUpWait:
        nextStep = OrderCreationStep.productSelection;
        add(LoadCategoriesWithProducts());
        break;
      default:
        nextStep = OrderCreationStep.orderTypeSelection;
        break;
    }

    emit(state.copyWith(
        selectedOrderType: event.selectedOrderType, step: nextStep));
  }

  Future<void> _onPhoneNumberEntered(
      PhoneNumberEntered event, Emitter<OrderCreationState> emit) async {
    emit(state.copyWith(phoneNumber: event.phoneNumber));
    emit(state.copyWith(step: OrderCreationStep.productSelection));
    add(LoadCategoriesWithProducts());
  }

  Future<void> _onDeliveryAddressEntered(
      DeliveryAddressEntered event, Emitter<OrderCreationState> emit) async {
    emit(state.copyWith(deliveryAddress: event.deliveryAddress));
  }

  Future<void> _onCustomerNameEntered(
      CustomerNameEntered event, Emitter<OrderCreationState> emit) async {
    emit(state.copyWith(customerName: event.customerName));
  }

  Future<void> _onOrderCommentsEntered(
      OrderCommentsEntered event, Emitter<OrderCreationState> emit) async {
    emit(state.copyWith(comments: event.comments));
  }

  Future<void> _onTimeSelected(
      TimeSelected event, Emitter<OrderCreationState> emit) async {
    emit(state.copyWith(scheduledDeliveryTime: event.time));
  }

  Future<void> _onAreaSelected(
      AreaSelected event, Emitter<OrderCreationState> emit) async {
    emit(state.copyWith(
      selectedAreaId: event.areaId,
      selectedAreaName:
          state.areas?.firstWhere((area) => area.id == event.areaId).name,
      selectedTableId: 0, // Asegúrate de resetear el selectedTableId aquí
    ));
    add(ResetTableSelection());
    add(LoadTables(areaId: event.areaId));
  }

  Future<void> _onResetTableSelection(
      ResetTableSelection event, Emitter<OrderCreationState> emit) async {
    emit(state.copyWith(
        tables: const [], selectedTableId: null, selectedTableNumber: null));
  }

  Future<void> _onTableSelected(
      TableSelected event, Emitter<OrderCreationState> emit) async {
    emit(state.copyWith(selectedTableId: event.tableId));
    final tableNumber =
        state.tables?.firstWhere((table) => table.id == event.tableId).number;
    emit(state.copyWith(selectedTableNumber: tableNumber));
  }

  Future<void> _onLoadAreas(
      LoadAreas event, Emitter<OrderCreationState> emit) async {
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
      LoadTables event, Emitter<OrderCreationState> emit) async {
    try {
      Resource response =
          await areasUseCases.getTablesFromArea.run(event.areaId);
      if (response is Success<List<appModel.Table>>) {
        List<appModel.Table> tables = response.data;
        emit(state.copyWith(tables: tables));
      } else {
        emit(state.copyWith(tables: [], response: response));
      }
    } catch (e) {
      emit(state.copyWith(tables: [], response: Error(e.toString())));
    }
  }

  void _onTableSelectionContinue(
      TableSelectionContinue event, Emitter<OrderCreationState> emit) {
    emit(state.copyWith(step: OrderCreationStep.productSelection));
    add(LoadCategoriesWithProducts());
  }

  Future<void> _onLoadCategoriesWithProducts(LoadCategoriesWithProducts event,
      Emitter<OrderCreationState> emit) async {
    emit(state.copyWith(response: Loading()));
    try {
      Resource response =
          await categoriesUseCases.getCategoriesWithProducts.run();
      if (response is Success<List<Category>>) {
        List<Category> categories = response.data;
        emit(state.copyWith(categories: categories));
      } else {
        emit(state.copyWith(categories: []));
      }
    } catch (e) {
      emit(state.copyWith(categories: []));
    }
  }

  Future<void> _onCategorySelected(
      CategorySelected event, Emitter<OrderCreationState> emit) async {
    Category? selectedCategory;
    try {
      selectedCategory =
          state.categories?.firstWhere((cat) => cat.id == event.categoryId);
    } catch (e) {
      // Si no se encuentra ninguna coincidencia, selectedCategory permanecerá como null.
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
      SubcategorySelected event, Emitter<OrderCreationState> emit) async {
    Subcategory? selectedSubcategory;
    try {
      selectedSubcategory = state.filteredSubcategories
          ?.firstWhere((sub) => sub.id == event.subcategoryId);
    } catch (e) {
      // Si no se encuentra ninguna coincidencia, selectedSubcategory permanecerá como null.
    }

    final filteredProducts = selectedSubcategory?.products ?? [];

    emit(state.copyWith(
      selectedSubcategoryId: event.subcategoryId,
      filteredProducts: filteredProducts,
    ));
  }

  Future<void> _onAddOrderItem(
      AddOrderItem event, Emitter<OrderCreationState> emit) async {
    // Añade el OrderItem proporcionado por el evento al estado actual
    final updatedOrderItems = List<OrderItem>.from(state.orderItems ?? [])
      ..add(event.orderItem);
    emit(state.copyWith(orderItems: updatedOrderItems));
  }

  Future<void> _onUpdateOrderItem(
      UpdateOrderItem event, Emitter<OrderCreationState> emit) async {
    final updatedOrderItems = state.orderItems?.map((orderItem) {
          return orderItem.tempId == event.orderItem.tempId
              ? event.orderItem
              : orderItem;
        }).toList() ??
        [];
    emit(state.copyWith(orderItems: updatedOrderItems));
  }

  Future<void> _onRemoveOrderItem(
      RemoveOrderItem event, Emitter<OrderCreationState> emit) async {
    final updatedOrderItems = state.orderItems
            ?.where((item) => item.tempId != event.tempId)
            .toList() ??
        [];

    emit(state.copyWith(orderItems: updatedOrderItems));
  }

  Future<void> _onSendOrder(
      SendOrder event, Emitter<OrderCreationState> emit) async {
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

    AuthResponse? userSession = await authUseCases.getUserSession.run();
    String? createdBy = userSession?.user.name;

    // Crear una nueva lista de OrderItem con solo el ID del producto y el ID del productVariant
    List<OrderItem> simplifiedOrderItems = state.orderItems?.map((orderItem) {
          return OrderItem(
            status: orderItem.status,
            comments: orderItem.comments,
            product: orderItem.product,
            productVariant: orderItem.productVariant,
            price: orderItem.price,
            selectedModifiers: orderItem.selectedModifiers,
            selectedProductObservations: orderItem.selectedProductObservations,
            selectedPizzaFlavors: orderItem.selectedPizzaFlavors,
            selectedPizzaIngredients: orderItem.selectedPizzaIngredients,
          );
        }).toList() ??
        [];

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

    // Crea la orden con el totalCost actualizado
    Order order = Order(
      orderType: state.selectedOrderType,
      status: OrderStatus.created,
      totalCost: state.totalCost, // Usa el totalCost del estado actualizado
      comments: state.comments,
      creationDate: DateTime.now(),
      scheduledDeliveryTime: scheduledDeliveryDateTime,
      createdBy: createdBy,
      phoneNumber: null,
      deliveryAddress: null,
      customerName: null,
      area: null,
      table: null,
      orderItems: simplifiedOrderItems,
      orderAdjustments: state.orderAdjustments,
    );

    // Asigna los campos específicos segn el tipo de orden
    switch (state.selectedOrderType) {
      case OrderType.dineIn:
        if (state.isTemporaryTableEnabled &&
            state.temporaryIdentifier != null) {
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
        break;
    }

    final result = await ordersUseCases.createOrder.run(order);
    if (result is Success<Order>) {
      emit(
          state.copyWith(response: Success<String>('Orden enviada con éxito')));
    } else if (result is Error<Order>) {
      emit(state.copyWith(response: Error<String>(result.message)));
    } else {
      emit(state.copyWith(response: Error<String>('Error al enviar la orden')));
    }
  }

  Future<void> _onResetResponse(
      ResetResponseEvent event, Emitter<OrderCreationState> emit) async {
    emit(state.copyWith(response: Initial()));
  }

  Future<void> _onOrderAdjustmentAdded(
      OrderAdjustmentAdded event, Emitter<OrderCreationState> emit) async {
    final uuid = Uuid();
    final orderAdjustment = event.orderAdjustment.copyWith(uuid: uuid.v4());
    List<OrderAdjustment> updatedOrderAdjustments =
        List.from(state.orderAdjustments ?? []);
    updatedOrderAdjustments.add(orderAdjustment);
    emit(state.copyWith(orderAdjustments: updatedOrderAdjustments));
  }

  Future<void> _onOrderAdjustmentRemoved(
      OrderAdjustmentRemoved event, Emitter<OrderCreationState> emit) async {
    List<OrderAdjustment> updatedOrderAdjustments =
        List.from(state.orderAdjustments ?? []);
    updatedOrderAdjustments.removeWhere(
        (adjustment) => adjustment.uuid == event.orderAdjustment.uuid);
    emit(state.copyWith(orderAdjustments: updatedOrderAdjustments));
  }

  Future<void> _onOrderAdjustmentUpdated(
      OrderAdjustmentUpdated event, Emitter<OrderCreationState> emit) async {
    List<OrderAdjustment> updatedOrderAdjustments =
        List.from(state.orderAdjustments ?? []);
    int index = updatedOrderAdjustments.indexWhere(
        (adjustment) => adjustment.uuid == event.orderAdjustment.uuid);
    if (index != -1) {
      updatedOrderAdjustments[index] = event.orderAdjustment;
    } else {
      updatedOrderAdjustments.add(event.orderAdjustment);
    }
    emit(state.copyWith(orderAdjustments: updatedOrderAdjustments));
  }

  Future<void> _onUpdateTotalCost(
      UpdateTotalCost event, Emitter<OrderCreationState> emit) async {
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

  Future<void> _onToggleTemporaryTable(
      ToggleTemporaryTable event, Emitter<OrderCreationState> emit) async {
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
      UpdateTemporaryIdentifier event, Emitter<OrderCreationState> emit) async {
    emit(state.copyWith(temporaryIdentifier: event.identifier));
  }
}
