import 'dart:ui';
import 'package:restaurante/src/domain/models/Order.dart';
import 'package:restaurante/src/domain/models/OrderItem.dart';
import 'package:restaurante/src/domain/models/Product.dart';
import 'package:restaurante/src/presentation/pages/preparation/pizza/bloc/PizzaPreparationEvent.dart';
import 'package:restaurante/src/presentation/pages/preparation/pizza/bloc/PizzaPreparationState.dart';
import 'package:restaurante/src/presentation/pages/preparation/pizza/bloc/PizzaPreparationBloc.dart';
import 'package:restaurante/src/presentation/pages/preparation/pizza/home/bloc/PizzaHomeState.dart';
import 'package:restaurante/src/presentation/widgets/OrderPizzaPreparationWidget.dart';
import 'package:restaurante/src/presentation/widgets/AdvancePreparationCounter.dart'; // Added import for the new widget
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

class PizzaPreparationPage extends StatefulWidget {
  final OrderFilterType filterType;
  final bool filterByPrepared;
  final bool filterByScheduledDelivery; // Nuevo parámetro
  final bool filterByCanBePreparedInAdvance; // Nuevo parámetro

  const PizzaPreparationPage(
      {Key? key,
      required this.filterType,
      this.filterByPrepared = false,
      this.filterByScheduledDelivery = false,
      this.filterByCanBePreparedInAdvance = false}) // Nuevo parámetro
      : super(key: key);

  @override
  _PizzaPreparationPageState createState() => _PizzaPreparationPageState();
}

class _PizzaPreparationPageState extends State<PizzaPreparationPage> {
  PizzaPreparationBloc? bloc;
  List<Order> filteredOrders = []; // Define la variable aquí
  bool _showAdvancePreparationCounter = false;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<PizzaPreparationBloc>(context, listen: false);
    bloc!.stream.listen((state) {
      _updateFilteredOrders(
          state); // Actualiza los pedidos filtrados cuando el estado cambia
    });
    // Establece la orientación preferida a horizontal al entrar a la página
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  void _updateFilteredOrders(PizzaPreparationState state) {
    setState(() {
      filteredOrders = state.orders?.where((order) {
            bool matchesType;
            switch (widget.filterType) {
              case OrderFilterType.delivery:
                matchesType = order.orderType == OrderType.delivery;
                break;
              case OrderFilterType.dineIn:
                matchesType = order.orderType == OrderType.dineIn ||
                    order.orderType == OrderType.pickUpWait;
                break;
              case OrderFilterType.all:
              default:
                matchesType = true;
                break;
            }

            bool matchesPreparedStatus =
                true; // Initialize as true to include all orders by default.
            if (widget.filterByPrepared) {
              // If the filter by prepared is active, only include orders that are prepared.
              matchesPreparedStatus = order.pizzaPreparationStatus ==
                  OrderPreparationStatus.prepared;
            } else {
              // If the filter by prepared is deactivated, exclude orders that are prepared.
              matchesPreparedStatus = order.pizzaPreparationStatus !=
                  OrderPreparationStatus.prepared;
            }

            bool matchesScheduledDelivery = true;
            if (widget.filterByScheduledDelivery) {
              matchesScheduledDelivery = order.scheduledDeliveryTime == null;
            }

            bool isWithinPreparationWindow = true;
            if (order.scheduledDeliveryTime != null) {
              final preparationWindow =
                  order.scheduledDeliveryTime!.subtract(Duration(minutes: 30));
              isWithinPreparationWindow =
                  DateTime.now().isAfter(preparationWindow);
            }

            bool matchesCanBePreparedInAdvance = true;
            if (widget.filterByCanBePreparedInAdvance) {
              matchesCanBePreparedInAdvance = order.orderItems!
                  .any((orderItem) => orderItem.canBePreparedInAdvance == true);
            }

            return matchesType &&
                matchesPreparedStatus &&
                matchesScheduledDelivery &&
                isWithinPreparationWindow &&
                matchesCanBePreparedInAdvance;
          }).toList() ??
          [];
    });
  }

  @override
  void dispose() {
    bloc?.disconnectWebSocket();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.dispose();
  }

  void synchronizeOrders() {
    bloc?.add(SynchronizeOrdersEvent());
  }

  void _handleOrderGesture(Order order, String gesture) {
    final bloc = BlocProvider.of<PizzaPreparationBloc>(context);
    switch (gesture) {
      case 'swipe_left':
        if (order.pizzaPreparationStatus != OrderPreparationStatus.prepared &&
            order.pizzaPreparationStatus !=
                OrderPreparationStatus.in_preparation) {
          bloc.add(UpdateOrderPreparationStatusEvent(
              order.id!,
              OrderPreparationStatus.in_preparation,
              PreparationStatusType.pizzaPreparationStatus));
        }
        break;
      case 'swipe_right':
        if (order.pizzaPreparationStatus != OrderPreparationStatus.prepared &&
            order.pizzaPreparationStatus != OrderPreparationStatus.created) {
          bloc.add(UpdateOrderPreparationStatusEvent(
              order.id!,
              OrderPreparationStatus.created,
              PreparationStatusType.pizzaPreparationStatus));
        }
        break;
      case 'swipe_to_prepared':
        bloc.add(UpdateOrderPreparationStatusEvent(
            order.id!,
            OrderPreparationStatus.prepared,
            PreparationStatusType.pizzaPreparationStatus));
        // Cambia el estado de todos los OrderItems visibles a preparado
        break;
      case 'swipe_to_in_preparation':
        bloc.add(UpdateOrderPreparationStatusEvent(
            order.id!,
            OrderPreparationStatus.in_preparation,
            PreparationStatusType.pizzaPreparationStatus));
        // No cambia el estado de los OrderItems aquí
        break;
    }
  }

  void _handleOrderItemTap(Order order, OrderItem orderItem) {
    Product? product =
        orderItem.product; // Asume que tienes acceso al producto aquí.
    final bloc = BlocProvider.of<PizzaPreparationBloc>(context);

    if (product?.subcategory?.name == "Pizzas" ||
        product?.subcategory?.name == "Entradas") {
      if (widget.filterByCanBePreparedInAdvance) {
        final newStatus = !orderItem.isBeingPreparedInAdvance!;
        bloc.add(UpdateOrderItemPreparationAdvanceStatusEvent(
            order.id!, orderItem.id!, newStatus));
      } else if (order.pizzaPreparationStatus ==
          OrderPreparationStatus.in_preparation) {
        final newStatus = orderItem.status == OrderItemStatus.prepared
            ? OrderItemStatus.in_preparation
            : OrderItemStatus.prepared;
        bloc.add(UpdateOrderItemStatusEvent(
            orderId: order.id!,
            orderItemId: orderItem.id!,
            newStatus: newStatus));
      }
      _updateFilteredOrders(bloc.state); // Update filtered orders after changes
    }
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController _scrollController = ScrollController();

    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              final bloc = BlocProvider.of<PizzaPreparationBloc>(context);
              bloc.add(SynchronizeOrdersEvent());
            },
            child: Icon(Icons.sync),
            heroTag: 'synchronizeOrders',
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                _showAdvancePreparationCounter =
                    !_showAdvancePreparationCounter;
              });
            },
            child: Icon(
              _showAdvancePreparationCounter
                  ? Icons.check_box
                  : Icons.check_box_outline_blank,
            ),
            heroTag: 'toggleAdvancePreparationCounter',
          ),
        ],
      ),
      body: Stack(
        children: [
          GestureDetector(
            onHorizontalDragUpdate: (details) {
              _scrollController.position
                  .moveTo(_scrollController.offset - details.primaryDelta!);
            },
            child: BlocBuilder<PizzaPreparationBloc, PizzaPreparationState>(
              builder: (context, state) {
                final orders = state.orders ?? [];
                filteredOrders = orders.where((order) {
                  bool matchesType;
                  switch (widget.filterType) {
                    case OrderFilterType.delivery:
                      matchesType = order.orderType == OrderType.delivery;
                      break;
                    case OrderFilterType.dineIn:
                      matchesType = order.orderType == OrderType.dineIn ||
                          order.orderType == OrderType.pickUpWait;
                      break;
                    case OrderFilterType.all:
                    default:
                      matchesType = true;
                      break;
                  }

                  bool matchesPreparedStatus =
                      true; // Inicializa como true para incluir todos los pedidos por defecto.
                  if (widget.filterByPrepared) {
                    // Si el filtro por preparados está activo, solo incluye los pedidos que están preparados.
                    matchesPreparedStatus = order.pizzaPreparationStatus ==
                        OrderPreparationStatus.prepared;
                  } else {
                    // Si el filtro por preparados está desactivado, excluye los pedidos que están preparados.
                    matchesPreparedStatus = order.pizzaPreparationStatus !=
                        OrderPreparationStatus.prepared;
                  }

                  bool matchesScheduledDelivery = true;
                  if (widget.filterByScheduledDelivery) {
                    matchesScheduledDelivery =
                        order.scheduledDeliveryTime == null;
                  }

                  bool isWithinPreparationWindow = true;
                  if (order.scheduledDeliveryTime != null) {
                    final preparationWindow = order.scheduledDeliveryTime!
                        .subtract(Duration(minutes: 30));
                    isWithinPreparationWindow =
                        DateTime.now().isAfter(preparationWindow);
                  }

                  bool matchesCanBePreparedInAdvance = true;
                  if (widget.filterByCanBePreparedInAdvance) {
                    matchesCanBePreparedInAdvance = order.orderItems!.any(
                        (orderItem) =>
                            orderItem.canBePreparedInAdvance == true);
                  }

                  return matchesType &&
                      matchesPreparedStatus &&
                      matchesScheduledDelivery &&
                      isWithinPreparationWindow &&
                      matchesCanBePreparedInAdvance;
                }).toList();

                if (filteredOrders.isEmpty) {
                  return Center(child: Text('No hay pedidos para mostrar.'));
                }

                return ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                    },
                  ),
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    physics:
                        const BouncingScrollPhysics(), // Agrega un efecto de rebote
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      List<OrderItem> filteredItems = widget
                              .filterByCanBePreparedInAdvance
                          ? order.orderItems!
                              .where((item) =>
                                  item.canBePreparedInAdvance == true &&
                                  item.status != OrderItemStatus.prepared)
                              .toList()
                          : List.from(order
                              .orderItems!); // Usa una copia de la lista si no hay filtro

                      if (order.pizzaPreparationStatus !=
                              OrderPreparationStatus.not_required &&
                          filteredItems.isNotEmpty) {
                        return OrderPizzaPreparationWidget(
                          order: order,
                          orderItems: filteredItems, // Pasa los items filtrados
                          onOrderGesture: _handleOrderGesture,
                          onOrderItemTap: _handleOrderItemTap,
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 5,
            right: 85,
            child: Visibility(
              visible: _showAdvancePreparationCounter,
              maintainState:
                  true, // Asegura que el estado interno se mantenga al ocultar el widget
              maintainSize: true, // Mantiene el tamaño del widget al ocultarlo
              maintainAnimation: true, // Mantiene las animaciones
              maintainInteractivity:
                  false, // Desactiva la interactividad cuando el widget está oculto
              child: AdvancePreparationCounter(orders: filteredOrders),
            ),
          ),
        ],
      ),
    );
  }
}
