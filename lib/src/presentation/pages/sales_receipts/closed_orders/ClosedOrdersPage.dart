import 'package:restaurante/src/domain/utils/Resource.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/closed_orders/ClosedOrderDetailsPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurante/src/domain/models/Order.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/closed_orders/bloc/ClosedOrdersBloc.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/closed_orders/bloc/ClosedOrdersEvent.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/closed_orders/bloc/ClosedOrdersState.dart';
import 'package:intl/intl.dart';

class ClosedOrdersPage extends StatefulWidget {
  @override
  _ClosedOrdersPageState createState() => _ClosedOrdersPageState();
}

class _ClosedOrdersPageState extends State<ClosedOrdersPage> {
  OrderType? selectedFilter; // null representa el filtro "Todas"

  @override
  Widget build(BuildContext context) {
    final ClosedOrdersBloc bloc = BlocProvider.of<ClosedOrdersBloc>(context);
    bloc.add(LoadClosedOrders());

    return Scaffold(
      appBar: AppBar(
        title: Text('Ordenes cerradas', style: TextStyle(fontSize: 24)),
        actions: <Widget>[
          DropdownButton<OrderType?>(
            value: selectedFilter,
            onChanged: (OrderType? newValue) {
              setState(() {
                selectedFilter = newValue;
              });
            },
            iconSize: 60, // Ajusta el tamaño del ícono del dropdown
            style: TextStyle(
                fontSize: 20,
                color: Colors.white), // Ajusta el estilo global del texto
            dropdownColor:
                Colors.black, // Cambia el color de fondo del men desplegable
            underline: Container(
              // Personaliza la línea debajo del dropdown
              height: 2,
              color: Colors.white,
            ),
            items: OrderType.values.map((orderType) {
              String displayText;
              switch (orderType) {
                case OrderType.delivery:
                  displayText = "A domicilio";
                  break;
                case OrderType.dineIn:
                  displayText = "Cenar";
                  break;
                case OrderType.pickUpWait:
                  displayText = "Pasan/Esperan";
                  break;
                default:
                  displayText = "Todas";
              }
              return DropdownMenuItem<OrderType?>(
                value: orderType,
                child: Text(displayText, style: TextStyle(fontSize: 20)),
              );
            }).toList()
              ..insert(
                  0,
                  DropdownMenuItem(
                    value: null,
                    child: Text("Todas", style: TextStyle(fontSize: 20)),
                  )),
          ),
        ],
      ),
      body: BlocBuilder<ClosedOrdersBloc, ClosedOrdersState>(
        builder: (context, state) {
          if (state.response is Loading) {
            return Center(child: CircularProgressIndicator());
          } else if (state.orders?.isNotEmpty ?? false) {
            List<Order> filteredOrders = selectedFilter == null
                ? state.orders!
                : state.orders!
                    .where((order) => order.orderType == selectedFilter)
                    .toList();

            return ListView.builder(
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                final order = filteredOrders[index];
                String title =
                    '#${order.id ?? ""}'; // Asegura que el ID siempre esté presente

                // Convierte la fecha de creación a la zona horaria local y la formatea
                String formattedDate = DateFormat('yyyy-MM-dd HH:mm')
                    .format(order.completionDate?.toLocal() ?? DateTime.now());
                String subtitle =
                    formattedDate; // Usa la fecha formateada como subtítulo

                // Agrega el scheduledDeliveryTime si está disponible, convirtiéndolo a la zona horaria local
                String scheduledDeliveryTimeText = '';
                if (order.scheduledDeliveryTime != null) {
                  String formattedScheduledDeliveryTime =
                      DateFormat('yyyy-MM-dd HH:mm')
                          .format(order.scheduledDeliveryTime!.toLocal());
                  scheduledDeliveryTimeText =
                      ' - programada: $formattedScheduledDeliveryTime';
                }

                // Agrega el tipo de pedido y detalles específicos según el tipo
                switch (order.orderType) {
                  case OrderType.delivery:
                    title += order.deliveryAddress != null
                        ? ' - ${order.deliveryAddress}'
                        : '';
                    title += order.phoneNumber != null
                        ? ' - Tel: ${order.phoneNumber}'
                        : '';
                    break;
                  case OrderType.dineIn:
                    title += ' - Dentro';
                    if (order.area != null && order.table != null) {
                      title +=
                          ' - ${order.area!.name} ${order.table!.number ?? order.table!.temporaryIdentifier}';
                    }
                    break;
                  case OrderType.pickUpWait:
                    title += ' - Recoger';
                    title += order.customerName != null
                        ? ' - ${order.customerName}'
                        : '';
                    break;
                  default:
                    // Maneja cualquier otro caso o tipo de pedido no especificado
                    break;
                }

                // Traduce el estado del pedido a español y cambia el color según el estado
                String statusText =
                    ' - Estado: ${_translateOrderStatus(order.status)}';
                Color statusColor = _getStatusColor(order.status);

                return ListTile(
                  title: Text(title, style: TextStyle(fontSize: 20)),
                  subtitle: Text(
                      subtitle + scheduledDeliveryTimeText + statusText,
                      style: TextStyle(color: statusColor, fontSize: 18)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ClosedOrderDetailsPage(order: order),
                      ),
                    );
                  },
                );
              },
            );
          } else if (state.response is Error) {
            final errorMessage = (state.response as Error).message;
            return Center(child: Text('Error: $errorMessage'));
          } else {
            return Center(child: Text('No hay órdenes cerradas.'));
          }
        },
      ),
    );
  }

  Color _getStatusColor(OrderStatus? status) {
    switch (status) {
      case OrderStatus.canceled:
        return Colors.red;
      case OrderStatus.finished:
        return Colors.grey;
      default:
        return Colors
            .black; // Color por defecto si el estado es nulo o no reconocido
    }
  }

  String _translateOrderStatus(OrderStatus? status) {
    switch (status) {
      case OrderStatus.canceled:
        return 'Cancelado';
      case OrderStatus.finished:
        return 'Finalizado';
      default:
        return 'Desconocido'; // Texto por defecto si el estado es nulo o no reconocido
    }
  }
}
