import 'package:restaurante/src/domain/models/Order.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/delivery_orders/bloc/DeliveryOrdersBloc.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/delivery_orders/bloc/DeliveryOrdersEvent.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/delivery_orders/bloc/DeliveryOrdersState.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeliveryOrdersPage extends StatefulWidget {
  @override
  _DeliveryOrdersPageState createState() => _DeliveryOrdersPageState();
}

class _DeliveryOrdersPageState extends State<DeliveryOrdersPage> {
  List<Order> selectedOrders = [];

  @override
  void initState() {
    super.initState();
    final DeliveryOrdersBloc bloc =
        BlocProvider.of<DeliveryOrdersBloc>(context, listen: false);
    bloc.add(LoadDeliveryOrders());
  }

  double getTotalCostOfSelectedOrders() {
    return selectedOrders.fold(
        0.0, (sum, order) => sum + (order.totalCost ?? 0.0));
  }

  @override
  Widget build(BuildContext context) {
    final DeliveryOrdersBloc bloc =
        BlocProvider.of<DeliveryOrdersBloc>(context);
    double totalCost = getTotalCostOfSelectedOrders();

    return Scaffold(
      appBar: AppBar(
        title: Text('Pedidos para Llevar'),
        actions: <Widget>[
          if (selectedOrders.isNotEmpty &&
              selectedOrders
                  .any((order) => order.status == OrderStatus.in_delivery))
            IconButton(
              icon: Icon(Icons.undo, size: 40),
              onPressed: () {
                // Revertir las órdenes seleccionadas a "Preparado"
                bloc.add(RevertOrdersToPrepared(selectedOrders
                    .where((order) => order.status == OrderStatus.in_delivery)
                    .toList()));
                setState(() {
                  selectedOrders.removeWhere(
                      (order) => order.status == OrderStatus.in_delivery);
                });
              },
            ),
          if (selectedOrders.isNotEmpty)
            SizedBox(width: 20), // Espacio entre iconos
          if (selectedOrders.isNotEmpty)
            IconButton(
              icon: Icon(Icons.send, size: 40),
              onPressed: () {
                // Asegurarse de enviar las órdenes seleccionadas antes de limpiar la lista
                bloc.add(MarkOrdersAsInDelivery(List.from(selectedOrders)));
                setState(() {
                  selectedOrders.clear();
                });
              },
            ),
          if (selectedOrders.isNotEmpty)
            SizedBox(width: 20), // Espacio entre iconos
          if (selectedOrders.isNotEmpty &&
              selectedOrders
                  .any((order) => order.status == OrderStatus.in_delivery))
            IconButton(
              icon: Icon(Icons.check_circle, size: 40),
              onPressed: () {
                // Marcar las órdenes seleccionadas como entregadas
                bloc.add(MarkOrdersAsDelivered(selectedOrders
                    .where((order) => order.status == OrderStatus.in_delivery)
                    .toList()));
                setState(() {
                  selectedOrders.removeWhere(
                      (order) => order.status == OrderStatus.in_delivery);
                });
              },
            ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Center(
              child: Text(
                'Total: \$${totalCost.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<DeliveryOrdersBloc, DeliveryOrdersState>(
        listener: (context, state) {
          if (state.response is Success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Operación realizada con éxito.',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          } else if (state.response is Error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Error: ${(state.response as Error).message}',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.response is Loading) {
            return Center(child: CircularProgressIndicator());
          } else if (state.orders?.isNotEmpty ?? false) {
            return ListView.builder(
              itemCount: state.orders!.length,
              itemBuilder: (context, index) {
                final order = state.orders![index];
                String statusText;
                Color textColor;
                switch (order.status) {
                  case OrderStatus.prepared:
                    statusText = 'Preparado';
                    textColor = Colors.green;
                    break;
                  case OrderStatus.in_delivery:
                    statusText = 'En reparto';
                    textColor = Colors.blue;
                    break;
                  default:
                    statusText = 'Desconocido';
                    textColor = Colors.grey;
                }
                return CheckboxListTile(
                  title: Text(
                    '#${order.id} - ${order.deliveryAddress}, Tel: ${order.phoneNumber}',
                    style: TextStyle(
                        color: textColor,
                        fontSize: 22), // Aumenta el tamaño aquí
                  ),
                  subtitle: Text(
                    'Total: \$${order.totalCost?.toStringAsFixed(2) ?? ''} - Estado: $statusText',
                    style: TextStyle(
                        color: textColor,
                        fontSize: 22), // Aumenta el tamaño aquí
                  ),
                  value: selectedOrders.contains(order),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value ?? false) {
                        selectedOrders.add(order);
                      } else {
                        selectedOrders.remove(order);
                      }
                      getTotalCostOfSelectedOrders();
                    });
                  },
                  activeColor: Colors.green,
                  checkColor: Colors.blue,
                );
              },
            );
          } else if (state.response is Error) {
            final errorMessage = (state.response as Error).message;
            return Center(child: Text('Error: $errorMessage'));
          } else {
            return Center(
                child: Text('No hay pedidos para llevar listos para entrega.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          bloc.add(LoadDeliveryOrders());
        },
        child: Icon(Icons.refresh),
      ),
    );
  }
}
