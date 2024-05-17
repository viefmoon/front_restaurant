import 'package:restaurante/src/domain/models/Order.dart';
import 'package:restaurante/src/domain/models/OrderItem.dart';
import 'package:restaurante/src/domain/models/Product.dart';
import 'package:restaurante/src/presentation/pages/preparation/bar/bloc/BarPreparationEvent.dart';
import 'package:restaurante/src/presentation/pages/preparation/bar/home/bloc/BarHomeState.dart';
import 'package:restaurante/src/presentation/widgets/OrderBarPreparationWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:restaurante/src/presentation/pages/preparation/bar/bloc/BarPreparationBloc.dart';
import 'package:restaurante/src/presentation/pages/preparation/bar/bloc/BarPreparationState.dart';

class BarPreparationPage extends StatefulWidget {
  final OrderFilterType filterType;
  final bool filterByPrepared;
  final bool filterByScheduledDelivery; // Nuevo parámetro

  const BarPreparationPage(
      {Key? key,
      required this.filterType,
      this.filterByPrepared = false,
      this.filterByScheduledDelivery = false}) // Nuevo parámetro
      : super(key: key);

  @override
  _BarPreparationPageState createState() => _BarPreparationPageState();
}

class _BarPreparationPageState extends State<BarPreparationPage> {
  BarPreparationBloc? bloc;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<BarPreparationBloc>(context, listen: false);
    // Establece la orientación preferida a horizontal al entrar a la página
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
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
    final bloc = BlocProvider.of<BarPreparationBloc>(context);
    switch (gesture) {
      case 'swipe_left':
        if (order.barPreparationStatus != OrderPreparationStatus.prepared &&
            order.barPreparationStatus !=
                OrderPreparationStatus.in_preparation) {
          bloc.add(UpdateOrderPreparationStatusEvent(
              order.id!,
              OrderPreparationStatus.in_preparation,
              PreparationStatusType.barPreparationStatus));
        }
        break;
      case 'swipe_right':
        if (order.barPreparationStatus != OrderPreparationStatus.prepared &&
            order.barPreparationStatus != OrderPreparationStatus.created) {
          bloc.add(UpdateOrderPreparationStatusEvent(
              order.id!,
              OrderPreparationStatus.created,
              PreparationStatusType.barPreparationStatus));
        }
        break;
      case 'swipe_to_prepared':
        bloc.add(UpdateOrderPreparationStatusEvent(
            order.id!,
            OrderPreparationStatus.prepared,
            PreparationStatusType.barPreparationStatus));
        // Cambia el estado de todos los OrderItems visibles a preparado
        break;
      case 'swipe_to_in_preparation':
        bloc.add(UpdateOrderPreparationStatusEvent(
            order.id!,
            OrderPreparationStatus.in_preparation,
            PreparationStatusType.barPreparationStatus));
        // No cambia el estado de los OrderItems aquí
        break;
    }
  }

  void _handleOrderItemTap(Order order, OrderItem orderItem) {
    Product? product = orderItem.product;

    if (order.barPreparationStatus == OrderPreparationStatus.in_preparation &&
        product?.subcategory?.category?.name == "Bebida") {
      // Verifica si es de la categoría "Bebidas"
      final bloc = BlocProvider.of<BarPreparationBloc>(context);
      final newStatus = orderItem.status == OrderItemStatus.prepared
          ? OrderItemStatus.in_preparation
          : OrderItemStatus.prepared;
      bloc.add(UpdateOrderItemStatusEvent(
          orderId: order.id!,
          orderItemId: orderItem.id!,
          newStatus: newStatus));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<BarPreparationBloc, BarPreparationState>(
        builder: (context, state) {
          final orders = state.orders ?? [];
          final filteredOrders = orders.where((order) {
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
              matchesPreparedStatus =
                  order.barPreparationStatus == OrderPreparationStatus.prepared;
            } else {
              // Si el filtro por preparados está desactivado, excluye los pedidos que están preparados.
              matchesPreparedStatus =
                  order.barPreparationStatus != OrderPreparationStatus.prepared;
            }

            bool matchesScheduledDelivery = true; // Por defecto, mostrar todos
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

            return matchesType &&
                matchesPreparedStatus &&
                matchesScheduledDelivery &&
                isWithinPreparationWindow;
          }).toList();

          if (filteredOrders.isEmpty) {
            return Center(child: Text('No hay pedidos para mostrar.'));
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: filteredOrders.length,
            itemBuilder: (context, index) {
              final order = filteredOrders[index];
              if (order.barPreparationStatus !=
                  OrderPreparationStatus.not_required) {
                return OrderBarPreparationWidget(
                  order: order,
                  onOrderGesture: _handleOrderGesture,
                  onOrderItemTap: _handleOrderItemTap,
                );
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final bloc = BlocProvider.of<BarPreparationBloc>(context);
          bloc.add(SynchronizeOrdersEvent());
        },
        child: Icon(Icons.sync),
      ),
    );
  }
}
