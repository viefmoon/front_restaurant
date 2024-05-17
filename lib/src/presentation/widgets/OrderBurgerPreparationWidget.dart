import 'dart:async';
import 'package:restaurante/src/domain/models/OrderItem.dart';
import 'package:restaurante/src/domain/models/OrderUpdate.dart';
import 'package:flutter/material.dart';
import 'package:restaurante/src/domain/models/Order.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

class OrderBurgerPreparationWidget extends StatefulWidget {
  final Order order;
  final Function(Order, String) onOrderGesture;
  final Function(Order, OrderItem) onOrderItemTap;

  const OrderBurgerPreparationWidget({
    //Key? key,
    required this.order,
    required this.onOrderGesture,
    required this.onOrderItemTap, // Agrega el callback al constructor
  });

  @override
  _OrderBurgerPreparationWidgetState createState() =>
      _OrderBurgerPreparationWidgetState();
}

class _OrderBurgerPreparationWidgetState
    extends State<OrderBurgerPreparationWidget> {
  Timer? _timer;
  Duration _timeSinceCreation = Duration.zero;
  Duration _timeUntilScheduled = Duration.zero; // Añadir esta línea
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _updateTimeSinceCreation();
    _updateTimeUntilScheduled(); // Añadir esta llamada
    _timer = Timer.periodic(Duration(minutes: 1), (Timer t) {
      _updateTimeSinceCreation();
      _updateTimeUntilScheduled(); // Añadir esta llamada
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _updateTimeSinceCreation() {
    if (widget.order.creationDate != null) {
      setState(() {
        _timeSinceCreation =
            DateTime.now().difference(widget.order.creationDate!);
      });
    }
  }

  void _updateTimeUntilScheduled() {
    if (widget.order.scheduledDeliveryTime != null) {
      final now = DateTime.now();
      final scheduledTime = widget.order.scheduledDeliveryTime!;
      final difference = scheduledTime.difference(now);
      setState(() {
        _timeUntilScheduled =
            difference.isNegative ? Duration.zero : difference;
      });
    }
  }

  @override
  void didUpdateWidget(covariant OrderBurgerPreparationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.order.scheduledDeliveryTime !=
        oldWidget.order.scheduledDeliveryTime) {
      _updateTimeUntilScheduled();
    }
  }

  Color _getColorBasedOnTime(Duration duration) {
    if (duration.inMinutes < 20) {
      return const Color.fromARGB(255, 29, 126, 32);
    } else if (duration.inMinutes < 50) {
      return const Color.fromARGB(255, 202, 143, 54);
    } else {
      return const Color.fromARGB(255, 226, 72, 25);
    }
  }

  List<Color> _updateColors = [
    Color.fromRGBO(212, 17, 203, 1),
    Color.fromARGB(255, 161, 106, 23),
    Color.fromARGB(255, 134, 24, 153),
    const Color.fromARGB(255, 88, 59, 48),
    const Color.fromARGB(255, 163, 14, 63),
    const Color.fromARGB(255, 172, 139, 42),
    const Color.fromARGB(255, 4, 78, 42)
  ];

  @override
  Widget build(BuildContext context) {
    final String timeSinceCreation =
        '${_timeSinceCreation.inHours.toString().padLeft(2, '0')}:${_timeSinceCreation.inMinutes.remainder(60).toString().padLeft(2, '0')}';
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.25,
      child: Card(
        margin: EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderHeader(timeSinceCreation),
              _buildOrderDetails(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderHeader(String timeSinceCreation) {
    // Añade el parámetro aquí
    return _OrderHeaderGestureDetector(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _getColorByOrderState(widget.order.burgerPreparationStatus),
              _getColorByOrderType(widget.order.orderType),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: const [0.95, 0.05],
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 7,
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Orden #${widget.order.id} - ${_displayOrderType(widget.order.orderType)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          fontFamily: 'Arial'),
                    ),
                    Text(
                      _displayOrderStatus(widget.order.burgerPreparationStatus),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.black,
                          fontSize: 18,
                          fontFamily: 'Arial',
                          fontStyle: FontStyle.italic),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1.0),
                      child: Text.rich(
                        TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Creado hace: ',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            TextSpan(
                              text: '$timeSinceCreation',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                      color: _getColorBasedOnTime(
                                          _timeSinceCreation)),
                            ),
                            TextSpan(
                              text: '- ${widget.order.createdBy}',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (widget.order.scheduledDeliveryTime != null)
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  'Programado: ${DateFormat('HH:mm').format(widget.order.scheduledDeliveryTime!.toLocal())}',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            TextSpan(
                              text:
                                  ' - En: ${_formatDuration(_timeUntilScheduled)}',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorByOrderType(OrderType? type) {
    switch (type) {
      case OrderType.delivery:
        return Colors.brown;
      case OrderType.dineIn:
        return Colors.green;
      case OrderType.pickUpWait:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getColorByOrderState(OrderPreparationStatus? status) {
    switch (status) {
      case OrderPreparationStatus.created:
        return Colors.lightBlue[100]!;
      case OrderPreparationStatus.in_preparation:
        return Colors.lightGreen[100]!;
      case OrderPreparationStatus.prepared:
        return Colors.amber[100]!;
      default:
        return Colors.white;
    }
  }

  Widget _OrderHeaderGestureDetector({required Widget child}) {
    return GestureDetector(
      onHorizontalDragEnd: _handleHorizontalDragEnd,
      onVerticalDragEnd: _handleVerticalDragEnd,
      onLongPress: () => _handleLongPress(widget.order), // Añade esto
      child: child,
    );
  }

  void _handleLongPress(Order order) {
    // Aquí implementas la lógica para cambiar el estado del pedido
    // basado en su estado actual
    String newStatus;
    if (order.burgerPreparationStatus == OrderPreparationStatus.created ||
        order.burgerPreparationStatus ==
            OrderPreparationStatus.in_preparation) {
      newStatus = 'swipe_to_prepared'; // Define un nuevo tipo de gesto
    } else if (order.burgerPreparationStatus ==
        OrderPreparationStatus.prepared) {
      newStatus = 'swipe_to_in_preparation'; // Define otro tipo de gesto
    } else {
      return; // No hagas nada si el pedido no está en un estado que pueda cambiar
    }

    // Llama al callback proporcionado al widget con el nuevo estado
    widget.onOrderGesture(order, newStatus);
  }

  Widget _buildOrderDetails(BuildContext context) {
    List<Widget> orderDetails = [];

    Widget buildSubHeaderDetail(String text, {List<OrderUpdate>? updates}) {
      List<Widget> children = [
        Text(
          text,
          style: TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.bold,
            fontFamily: 'Calibri',
          ),
        ),
        Divider(
            color: Colors
                .black), // Añade esta línea para insertar la barra divisoria
      ];

      if (updates != null && updates.isNotEmpty) {
        children.addAll(updates.map((update) {
          final timeAgo = DateTime.now().difference(update.updateAt);
          final formattedTimeAgo = _formatDuration(timeAgo);
          final color =
              _updateColors[update.updateNumber % _updateColors.length];
          return Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              'Actualizado: $formattedTimeAgo por ${update.updatedBy}',
              style: TextStyle(
                fontSize: 15,
                fontStyle: FontStyle.italic,
                color: color,
                height: 1,
              ),
            ),
          );
        }).toList());
      }

      return Container(
        width: double.infinity,
        color: Color.fromARGB(255, 222, 226, 235),
        padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      );
    }

    // Añadir detalles basados en el tipo de orden
    switch (widget.order.orderType) {
      case OrderType.delivery:
        String detallesDelivery =
            'Dirección: ${widget.order.deliveryAddress}\nTeléfono: ${widget.order.phoneNumber}';
        if (widget.order.comments != null &&
            widget.order.comments!.isNotEmpty) {
          detallesDelivery += '\nComentarios: ${widget.order.comments}';
        }
        orderDetails.add(buildSubHeaderDetail(detallesDelivery,
            updates: widget.order.orderUpdates));
        break;
      case OrderType.dineIn:
        String detallesDineIn =
            '${widget.order.area?.name} - ${widget.order.table?.number ?? widget.order.table?.temporaryIdentifier}';
        if (widget.order.comments != null &&
            widget.order.comments!.isNotEmpty) {
          detallesDineIn += '\nComentarios: ${widget.order.comments}';
        }
        orderDetails.add(buildSubHeaderDetail(detallesDineIn,
            updates: widget.order.orderUpdates));
        break;
      case OrderType.pickUpWait:
        String detallesPickUpWait =
            'Cliente: ${widget.order.customerName}\nTeléfono: ${widget.order.phoneNumber}';
        if (widget.order.comments != null &&
            widget.order.comments!.isNotEmpty) {
          detallesPickUpWait += '\nComentarios: ${widget.order.comments}';
        }
        orderDetails.add(buildSubHeaderDetail(detallesPickUpWait,
            updates: widget.order.orderUpdates));
        break;
      default:
        orderDetails.add(SizedBox
            .shrink()); // En caso de que el tipo de orden no esté definido
    }

    // Añadir detalles de los OrderItems
    widget.order.orderItems?.reversed
        .toList()
        .asMap()
        .forEach((index, orderItem) {
      // Encuentra la actualización más reciente para este OrderItem
      OrderUpdate? latestUpdateForItem =
          widget.order.orderUpdates?.lastWhereOrNull(
        (update) =>
            update.orderItemUpdates?.any(
                (itemUpdate) => itemUpdate.orderItem?.id == orderItem.id) ??
            false,
      );

      // Si existe, obtén el color basado en el OrderItemUpdate
      Color colorForItem = latestUpdateForItem != null
          ? _updateColors[
              latestUpdateForItem.updateNumber % _updateColors.length]
          : Colors.black;

      if (index > 0) {
        // Añadir un Divider antes de cada OrderItem, excepto el primero
        orderDetails.add(Divider(color: Colors.black));
      }

      TextStyle baseTextStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                fontFamily: 'Arial',
              ) ??
          TextStyle();

      TextStyle smallerTextStyle =
          Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ) ??
              TextStyle();

      TextStyle textStyle = orderItem.status == OrderItemStatus.prepared
          ? baseTextStyle.copyWith(
              decoration: TextDecoration.lineThrough,
              decorationColor: Colors.black,
              decorationThickness: 3,
              decorationStyle: TextDecorationStyle.solid,
              color: colorForItem,
            )
          : baseTextStyle.copyWith(color: colorForItem);

      TextStyle smallerDecoratedTextStyle =
          orderItem.status == OrderItemStatus.prepared
              ? smallerTextStyle.copyWith(
                  decoration: TextDecoration.lineThrough,
                  decorationColor: Colors.black,
                  decorationThickness: 2,
                  decorationStyle: TextDecorationStyle.solid,
                  color: colorForItem,
                )
              : smallerTextStyle.copyWith(color: colorForItem);

      TextStyle commentsTextStyle = orderItem.status == OrderItemStatus.prepared
          ? smallerTextStyle.copyWith(
              decoration: TextDecoration.lineThrough,
              decorationColor: Colors.black,
              decorationThickness: 2,
              decorationStyle: TextDecorationStyle.solid,
              color: Colors.black,
            )
          : smallerTextStyle.copyWith(color: Colors.black);

      List<Widget> itemWidgets = [
        if (orderItem.productVariant != null)
          Text(
            orderItem.productVariant!.name,
            style: textStyle.copyWith(color: colorForItem),
          ),
        if (orderItem.productVariant == null)
          Text(
            orderItem.product?.name ?? 'Producto desconocido',
            style: textStyle.copyWith(color: colorForItem),
          ),
        ...orderItem.selectedModifiers?.map((modifier) => Text(
                  modifier.modifier!.name,
                  style:
                      smallerDecoratedTextStyle.copyWith(color: colorForItem),
                )) ??
            [],
        ...orderItem.selectedProductObservations?.map((observation) => Text(
                  observation.productObservation!.name,
                  style:
                      smallerDecoratedTextStyle.copyWith(color: colorForItem),
                )) ??
            [],
      ];

      // Añadir comentarios del OrderItem si existen
      if (orderItem.comments != null && orderItem.comments!.isNotEmpty) {
        itemWidgets.add(Text(
          'Comentarios: ${orderItem.comments}',
          style: commentsTextStyle,
        ));
      }
      orderDetails.add(
        GestureDetector(
          onTap: () {
            widget.onOrderItemTap(widget.order, orderItem);
          },
          child: Container(
            padding: EdgeInsets.only(top: 5, bottom: 5),
            color: Colors.transparent,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: itemWidgets,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: orderDetails,
    );
  }

  String _displayOrderType(OrderType? type) {
    switch (type) {
      case OrderType.delivery:
        return 'Domicilio';
      case OrderType.dineIn:
        return 'Dentro';
      case OrderType.pickUpWait:
        return 'Pasan/Esperan';
      default:
        return 'Desconocido';
    }
  }

  String _displayOrderStatus(OrderPreparationStatus? status) {
    switch (status) {
      case OrderPreparationStatus.created:
        return 'Creada';
      case OrderPreparationStatus.in_preparation:
        return 'En preparación';
      case OrderPreparationStatus.prepared:
        return 'Preparada';
      default:
        return 'Desconocido';
    }
  }

  // Esta función ayuda a formatear la duración a un formato legible
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    return "$hours:$minutes";
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    const double velocityThreshold =
        50.0; // Ajusta este valor según tus necesidades
    if (details.primaryVelocity! > velocityThreshold) {
      widget.onOrderGesture(widget.order, 'swipe_right');
    } else if (details.primaryVelocity! < -velocityThreshold) {
      widget.onOrderGesture(widget.order, 'swipe_left');
    }
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    const double velocityThreshold =
        50.0; // Ajusta este valor según tus necesidades
    if (details.primaryVelocity! > velocityThreshold) {
      widget.onOrderGesture(widget.order, 'swipe_down');
    } else if (details.primaryVelocity! < -velocityThreshold) {
      widget.onOrderGesture(widget.order, 'swipe_up');
    }
  }
}
