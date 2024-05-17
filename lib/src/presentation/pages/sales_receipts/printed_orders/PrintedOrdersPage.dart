import 'package:restaurante/src/domain/models/Order.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/printed_orders/bloc/PrintedOrdersBloc.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/printed_orders/bloc/PrintedOrdersEvent.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/printed_orders/bloc/PrintedOrdersState.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class PrintedOrdersPage extends StatefulWidget {
  @override
  _PrintedOrdersPageState createState() => _PrintedOrdersPageState();
}

class _PrintedOrdersPageState extends State<PrintedOrdersPage> {
  List<Order> selectedOrders = [];

  @override
  void initState() {
    super.initState();
    final PrintedOrdersBloc bloc =
        BlocProvider.of<PrintedOrdersBloc>(context, listen: false);
    bloc.add(LoadPrintedOrders());
  }

  @override
  Widget build(BuildContext context) {
    final PrintedOrdersBloc bloc = BlocProvider.of<PrintedOrdersBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Finalizar tickets pendientes de pago'),
        actions: <Widget>[
          if (selectedOrders.isNotEmpty)
            IconButton(
              icon: Icon(Icons.check_circle, size: 42), // Icono más grande
              onPressed: () {
                bloc.add(MarkOrdersAsPaid(List.from(selectedOrders)));
                setState(() {
                  selectedOrders.clear();
                });
              },
            ),
        ],
      ),
      body: BlocConsumer<PrintedOrdersBloc, PrintedOrdersState>(
        listener: (context, state) {
          if (state.response is Success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Órdenes marcadas como pagadas exitosamente.',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors
                          .white), // Aumenta el tamaño del texto y cambia el color a blanco
                ),
                backgroundColor: Colors.green, // Fondo verde para éxito
                duration: Duration(seconds: 1),
              ),
            );
          } else if (state.response is Error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Error al marcar las órdenes como pagadas: ${(state.response as Error).message}',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors
                          .white), // Aumenta el tamaño del texto y cambia el color a blanco
                ),
                backgroundColor: Colors.red, // Fondo rojo para error
                duration: Duration(seconds: 1),
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
                  case OrderStatus.created:
                    statusText = 'Creada';
                    textColor = Colors.white;
                    break;
                  case OrderStatus.in_preparation:
                    statusText = 'En preparación';
                    textColor = Colors.orange;
                    break;
                  case OrderStatus.prepared:
                    statusText = 'Preparado';
                    textColor = Colors.green;
                    break;
                  default:
                    statusText = 'Desconocido';
                    textColor = Colors.grey;
                }
                String title = 'Orden #${order.id}';
                if (order.orderType == OrderType.dineIn) {
                  title = 'Orden #${order.id}';
                  if (order.area != null) {
                    if (order.table != null && order.table!.number != null) {
                      title += ' - ${order.area!.name} ${order.table!.number}';
                    } else if (order.table != null &&
                        order.table!.temporaryIdentifier != null) {
                      title +=
                          ' - ${order.area!.name} ${order.table!.temporaryIdentifier}';
                    }
                  }
                }
                String printDetails = '';
                if (order.orderPrints != null) {
                  for (var print in order.orderPrints!) {
                    printDetails +=
                        'Impreso por: ${print.printedBy}, ${DateFormat('yyyy-MM-dd HH:mm').format(print.printTime ?? DateTime.now())}\n';
                  }
                }
                return CheckboxListTile(
                  title: Text(
                    title,
                    style: TextStyle(fontSize: 22, color: textColor),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total: \$${order.totalCost?.toStringAsFixed(2) ?? ''} - Estado: $statusText',
                        style: TextStyle(
                            fontSize: 22, // Tamaño más grande para "Total"
                            color: textColor),
                      ),
                      Text(
                        printDetails
                            .trim(), // Usar trim() para eliminar espacios extra al final
                        style: TextStyle(
                            fontSize:
                                16, // Tamaño más pequeño para "Impreso por"
                            color: textColor),
                      ),
                    ],
                  ),
                  value: selectedOrders.contains(order),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value ?? false) {
                        selectedOrders.add(order);
                      } else {
                        selectedOrders.remove(order);
                      }
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
            return Center(child: Text('No hay pedidos impresos.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          bloc.add(LoadPrintedOrders());
        },
        child: Icon(Icons.refresh),
      ),
    );
  }
}
