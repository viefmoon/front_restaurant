import 'package:restaurante/src/domain/models/AuthResponse.dart';
import 'package:restaurante/src/domain/models/Order.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales/order_update/OrderUpdatePage.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales/order_update/bloc/OrderUpdateEvent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales/order_update/bloc/OrderUpdateBloc.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales/order_update/bloc/OrderUpdateState.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';
import 'package:intl/intl.dart';

class OpenOrdersPage extends StatefulWidget {
  @override
  _OpenOrdersPageState createState() => _OpenOrdersPageState();
}

class _OpenOrdersPageState extends State<OpenOrdersPage> {
  OrderType? selectedFilter; // null representa el filtro "Todas"
  String? selectedArea; // null representa "Todas las áreas"
  TextEditingController deliveryAddressController = TextEditingController();
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _initializeFiltersBasedOnRole();
  }

  Future<void> _initializeFiltersBasedOnRole() async {
    _userRole = await _getUserRole(context);
    if (_userRole == "Mesero") {
      setState(() {
        selectedFilter = OrderType.dineIn;
      });
    }
  }

  Future<String?> _getUserRole(BuildContext context) async {
    AuthResponse? userSession = await BlocProvider.of<OrderUpdateBloc>(context)
        .authUseCases
        .getUserSession
        .run();
    return userSession?.user.roles?.isNotEmpty == true
        ? userSession?.user.roles!.first.name
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final OrderUpdateBloc bloc = BlocProvider.of<OrderUpdateBloc>(context);
    bloc.add(LoadOpenOrders());

    return Scaffold(
      appBar: AppBar(
        title: Text('Órdenes Abiertas', style: TextStyle(fontSize: 24)),
        actions: <Widget>[
          DropdownButton<OrderType?>(
            value: selectedFilter,
            onChanged: (OrderType? newValue) {
              setState(() {
                selectedFilter = newValue;
                if (newValue != OrderType.dineIn) {
                  selectedArea =
                      null; // Resetea el filtro de área si no es 'Cenar'
                }
              });
            },
            iconSize: 20,
            style: TextStyle(fontSize: 20, color: Colors.white),
            dropdownColor: Colors.black,
            underline: Container(height: 2, color: Colors.white),
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
                      child: Text("Todas", style: TextStyle(fontSize: 20)))),
          ),
          SizedBox(width: 5),
          if (selectedFilter ==
              OrderType
                  .dineIn) // Solo muestra este dropdown si el filtro es 'Cenar'
            DropdownButton<String?>(
              value: selectedArea,
              onChanged: (String? newValue) {
                setState(() {
                  selectedArea = newValue;
                });
              },
              iconSize: 20,
              style: TextStyle(fontSize: 20, color: Colors.white),
              dropdownColor: Colors.black,
              underline: Container(height: 2, color: Colors.white),
              items: ['ARCO', 'BAR', 'ENTRADA', 'EQUIPAL', 'JARDIN']
                  .map((String area) {
                return DropdownMenuItem<String?>(
                  value: area,
                  child: Text(area, style: TextStyle(fontSize: 20)),
                );
              }).toList()
                ..insert(
                    0,
                    DropdownMenuItem(
                        value: null,
                        child: Text("Todas las áreas",
                            style: TextStyle(fontSize: 20)))),
            ),
        ],
      ),
      body: Column(
        children: [
          if (selectedFilter == OrderType.delivery) // Paso 2
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: deliveryAddressController,
                decoration: InputDecoration(
                  labelText: 'Buscar por dirección de entrega',
                  suffixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  setState(() {}); // Actualiza la UI con cada cambio de texto
                },
              ),
            ),
          Expanded(
            child: BlocBuilder<OrderUpdateBloc, OrderUpdateState>(
              builder: (context, state) {
                if (state.response is Loading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state.orders?.isNotEmpty ?? false) {
                  List<Order> filteredOrders = selectedFilter == null
                      ? state.orders!
                      : state.orders!
                          .where((order) => order.orderType == selectedFilter)
                          .toList();

                  if (selectedFilter == OrderType.delivery &&
                      deliveryAddressController.text.isNotEmpty) {
                    filteredOrders = filteredOrders
                        .where((order) =>
                            order.deliveryAddress != null &&
                            order.deliveryAddress!.toLowerCase().contains(
                                deliveryAddressController.text.toLowerCase()))
                        .toList();
                  }

                  if (selectedFilter == OrderType.dineIn &&
                      selectedArea != null) {
                    filteredOrders = filteredOrders
                        .where((order) =>
                            order.area != null &&
                            order.area!.name == selectedArea)
                        .toList();
                  }

                  return ListView.builder(
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      String title =
                          '#${order.id ?? ""}'; // Asegura que el ID siempre esté presente

                      // Convierte la fecha de creación a la zona horaria local y la formatea
                      String formattedDate = DateFormat('yyyy-MM-dd HH:mm')
                          .format(
                              order.creationDate?.toLocal() ?? DateTime.now());
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
                          if (order.area != null) {
                            if (order.table != null &&
                                order.table!.number != null) {
                              title +=
                                  ' - ${order.area!.name} ${order.table!.number}';
                            } else if (order.table != null &&
                                order.table!.temporaryIdentifier != null) {
                              title +=
                                  ' - ${order.area!.name} ${order.table!.temporaryIdentifier}';
                            }
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
                          // Emitir el evento al BLoC con la orden seleccionada
                          bloc.add(OrderSelectedForUpdate(order));

                          // Navegar a la página de actualización de la orden sin pasar la orden como parámetro
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  OrderUpdatePage(), // Ahora OrderUpdatePage no necesita parámetros
                            ),
                          );
                        },
                        // Agrega más detalles según sea necesario
                      );
                    },
                  );
                } else if (state.response is Error) {
                  final errorMessage = (state.response as Error).message;
                  return Center(child: Text('Error: $errorMessage'));
                } else {
                  return Center(child: Text('No hay órdenes abiertas.'));
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          bloc.add(LoadOpenOrders());
        },
        child: Icon(Icons.refresh),
      ),
    );
  }

  // Añade esta función dentro de la clase OpenOrdersPage para determinar el color basado en el estado
  Color _getStatusColor(OrderStatus? status) {
    switch (status) {
      case OrderStatus.created:
        return Colors.blue;
      case OrderStatus.in_preparation:
        return Colors.orange;
      case OrderStatus.prepared:
        return Colors.green;
      case OrderStatus.in_delivery:
        return Colors.indigo;
      case OrderStatus.finished:
        return Colors.grey;
      case OrderStatus.canceled:
        return Colors.red;
      default:
        return Colors
            .black; // Color por defecto si el estado es nulo o no reconocido
    }
  }

  // Añade esta función dentro de la clase OpenOrdersPage para traducir el estado a español
  String _translateOrderStatus(OrderStatus? status) {
    switch (status) {
      case OrderStatus.created:
        return 'Creado';
      case OrderStatus.in_preparation:
        return 'En preparación';
      case OrderStatus.prepared:
        return 'Preparado';
      case OrderStatus.in_delivery:
        return 'En reparto';
      case OrderStatus.finished:
        return 'Finalizado';
      case OrderStatus.canceled:
        return 'Cancelado';
      default:
        return 'Desconocido'; // Texto por defecto si el estado es nulo o no reconocido
    }
  }
}
