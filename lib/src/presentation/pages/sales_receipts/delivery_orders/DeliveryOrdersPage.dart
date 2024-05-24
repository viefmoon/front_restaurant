import 'package:restaurante/src/domain/models/Order.dart';
import 'package:restaurante/src/domain/models/SelectedPizzaIngredient.dart';
import 'package:restaurante/src/domain/utils/Resource.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/delivery_orders/bloc/DeliveryOrdersBloc.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/delivery_orders/bloc/DeliveryOrdersEvent.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/delivery_orders/bloc/DeliveryOrdersState.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

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

  String _generateTicketContent(Order order) {
    String content = '';
    String cmdFontSizeLarge =
        "\x1d\x21\x12"; // Ajusta este valor según tu impresora
    String cmdFontSizeNormal =
        "\x1d\x21\x00"; // Comando para restablecer el tamaño de la fuente a normal

    // Comandos para activar/desactivar negrita
    String cmdBoldOn = "\x1b\x45\x01";
    String cmdBoldOff = "\x1b\x45\x00";

    // Comando para centrar el texto
    String cmdAlignCenter = "\x1b\x61\x01";

    // Añadir "Orden" con el tamaño de fuente grande y en negrita
    content += cmdBoldOn +
        cmdFontSizeLarge +
        'Orden #${order.id}\n\n' +
        cmdBoldOff +
        cmdFontSizeNormal;

    // Imprimir el tipo de orden (Entrega a domicilio)
    content += cmdAlignCenter + 'Entrega a domicilio\n\n';

    // Alinear los detalles de la orden a la izquierda
    content += "\x1b\x61\x00"; // Comando para alinear el texto a la izquierda

    // Imprimir detalles de la orden
    content += 'Telefono: ${order.phoneNumber}\n';
    content += 'Direccion: ${order.deliveryAddress}\n';

    // Añadir la fecha de impresión del ticket formateada hasta el minuto
    content += 'Fecha: ${DateTime.now().toString().substring(0, 16)}\n';
    content +=
        '--------------------------------\n'; // Línea de separación con guiones

    // Imprimir los detalles de los productos de la orden
    order.orderItems?.forEach((item) {
      final int lineWidth = 32; // Ajusta según el ancho de tu impresora
      // Determina si se debe usar el nombre de la variante o el nombre del producto
      String productName =
          item.productVariant?.name ?? item.product?.name ?? '';
      String productPrice = '\$${item.price?.toStringAsFixed(2) ?? ''}';

      // Calcula el espacio máximo disponible para el nombre del producto o variante
      int maxProductNameLength = lineWidth -
          productPrice.length -
          1; // -1 por el espacio entre nombre y precio

      // Trunca el nombre del producto o variante si es necesario
      if (productName.length > maxProductNameLength) {
        productName =
            productName.substring(0, maxProductNameLength - 3) + '...';
      }

      // Calcula el espacio restante después de colocar el nombre truncado y el precio
      int spaceNeeded = lineWidth - productName.length - productPrice.length;
      String spaces = ' ' * (spaceNeeded > 0 ? spaceNeeded : 0);

      content += productName + spaces + productPrice + '\n';

      // Función para agregar espacios al inicio de cada línea de un detalle
      String addPrefixToEachLine(String text, String prefix) {
        return text.split('\n').map((line) => prefix + line).join('\n');
      }

      // Define un prefijo de espacios para los detalles adicionales
      String detailPrefix = '  '; // 4 espacios de indentación

      // Agrega detalles adicionales como modificadores, ingredientes, etc.
      if (item.selectedModifiers != null &&
          item.selectedModifiers!.isNotEmpty) {
        String modifiersText =
            'Modificadores: ${item.selectedModifiers!.map((m) => m.modifier?.name).join(', ')}';
        content += addPrefixToEachLine(modifiersText, detailPrefix) + '\n';
      }
      if (item.selectedPizzaFlavors != null &&
          item.selectedPizzaFlavors!.isNotEmpty) {
        String flavorsText =
            'Sabor: ${item.selectedPizzaFlavors!.map((f) => f.pizzaFlavor?.name).join('/')}';
        content += addPrefixToEachLine(flavorsText, detailPrefix) + '\n';
      }
      if (item.selectedPizzaIngredients != null &&
          item.selectedPizzaIngredients!.isNotEmpty) {
        String ingredientsText = '';
        final ingredientsLeft = item.selectedPizzaIngredients!
            .where((i) => i.half == PizzaHalf.left)
            .map((i) => i.pizzaIngredient?.name)
            .join(', ');
        final ingredientsRight = item.selectedPizzaIngredients!
            .where((i) => i.half == PizzaHalf.right)
            .map((i) => i.pizzaIngredient?.name)
            .join(', ');
        final ingredientsNone = item.selectedPizzaIngredients!
            .where((i) => i.half == PizzaHalf.none)
            .map((i) => i.pizzaIngredient?.name)
            .join(', ');

        if (ingredientsLeft.isNotEmpty) {
          ingredientsText += 'Mitad 1: $ingredientsLeft';
        }
        if (ingredientsRight.isNotEmpty) {
          if (ingredientsText.isNotEmpty) ingredientsText += ' | ';
          ingredientsText += 'Mitad 2: $ingredientsRight';
        }
        if (ingredientsNone.isNotEmpty) {
          if (ingredientsText.isNotEmpty) ingredientsText += ' | ';
          ingredientsText += 'Completa: $ingredientsNone';
        }

        content += addPrefixToEachLine(ingredientsText, detailPrefix) + '\n';
      }
    });
    // Procesamiento de los ajustes de la orden
    order.orderAdjustments?.forEach((adjustment) {
      final int lineWidth = 32;
      String adjustmentName = adjustment.name ?? '';
      String adjustmentAmount = adjustment.amount! < 0
          ? '-\$${(-adjustment.amount!).toStringAsFixed(2)}'
          : '\$${adjustment.amount?.toStringAsFixed(2) ?? ''}';

      int maxAdjustmentNameLength = lineWidth - adjustmentAmount.length - 1;
      if (adjustmentName.length > maxAdjustmentNameLength) {
        adjustmentName =
            adjustmentName.substring(0, maxAdjustmentNameLength - 3) + '...';
      }

      int spaceNeeded =
          lineWidth - adjustmentName.length - adjustmentAmount.length;
      String spaces = ' ' * (spaceNeeded > 0 ? spaceNeeded : 0);

      content += adjustmentName + spaces + adjustmentAmount + '\n';
    });

    content +=
        '--------------------------------\n'; // Línea de separación con guiones
    content +=
        cmdFontSizeLarge + 'Total: \$${order.totalCost?.toStringAsFixed(2)}\n';

    // Verifica si hay un pago registrado
    if (order.amountPaid != null && order.amountPaid! > 0) {
      content += 'Pagado: \$${order.amountPaid?.toStringAsFixed(2)}\n';
      content +=
          'Resto: \$${(order.totalCost! - order.amountPaid!).toStringAsFixed(2)}\n' +
              cmdFontSizeNormal;
    }

    // Añade un mensaje de gracias después del total
    content += cmdAlignCenter + '\n" Gracias por su preferencia "\n';

    content += '\n\n\n';
    return content;
  }

  Future<void> _selectAndPrintTicket(Order order) async {
    BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

    // Verificar si ya está conectado y desconectar si es necesario
    bool? isConnected = await bluetooth.isConnected;
    if (isConnected != null && isConnected) {
      await bluetooth.disconnect();
    }

    // Obtener dispositivos emparejados
    List<BluetoothDevice> devices = await bluetooth.getBondedDevices();
    if (devices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se encontraron impresoras Bluetooth.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Muestra un diálogo para seleccionar la impresora
    BluetoothDevice? selectedDevice = await showDialog<BluetoothDevice>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Seleccionar impresora'),
          content: SingleChildScrollView(
            child: ListBody(
              children: devices
                  .map((device) => RadioListTile<BluetoothDevice>(
                        title: Text(device.name ?? ''),
                        value: device,
                        groupValue:
                            null, // No hay ninguna impresora seleccionada inicialmente
                        onChanged: (BluetoothDevice? value) {
                          Navigator.pop(context, value);
                        },
                      ))
                  .toList(),
            ),
          ),
        );
      },
    );

    if (selectedDevice != null) {
      try {
        // Conectar con la impresora seleccionada
        await bluetooth.connect(selectedDevice);

        // Agregar un retraso antes de imprimir
        await Future.delayed(Duration(milliseconds: 500));

        // Generar el contenido del ticket
        String ticketContent = _generateTicketContent(order);

        // Imprimir el ticket
        await bluetooth.printCustom(ticketContent, 0, 1);

        // Desconectar de la impresora
        await bluetooth.disconnect();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ticket impreso correctamente.'),
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al imprimir el ticket: $e'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _printOrder(Order order) {
    _selectAndPrintTicket(order);
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
                Color paymentStatusColor;
                switch (order.status) {
                  case OrderStatus.prepared:
                    statusText = 'Preparado';
                    textColor = Colors.green;
                    paymentStatusColor = order.amountPaid != null &&
                            order.totalCost != null &&
                            order.amountPaid! >= order.totalCost!
                        ? Colors.green
                        : Colors.red;
                    break;
                  case OrderStatus.in_delivery:
                    statusText = 'En reparto';
                    textColor = Colors.blue;
                    paymentStatusColor = order.amountPaid != null &&
                            order.totalCost != null &&
                            order.amountPaid! >= order.totalCost!
                        ? Colors.green
                        : Colors.red;
                    break;
                  default:
                    statusText = 'Desconocido';
                    textColor = Colors.grey;
                    paymentStatusColor = Colors.grey;
                }
                return Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        title: Text(
                          '#${order.id} - ${order.deliveryAddress}, Tel: ${order.phoneNumber}',
                          style: TextStyle(
                              color: textColor,
                              fontSize: 22), // Aumenta el tamaño aquí
                        ),
                        subtitle: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    'Total: \$${order.totalCost?.toStringAsFixed(2) ?? ''} - Estado: $statusText',
                                style: TextStyle(
                                    color: textColor,
                                    fontSize: 22), // Aumenta el tamaño aquí
                              ),
                              TextSpan(
                                text: order.amountPaid != null &&
                                        order.totalCost != null &&
                                        order.amountPaid! >= order.totalCost!
                                    ? ' (PAGADO)'
                                    : ' (NO PAGADO)',
                                style: TextStyle(
                                    color: paymentStatusColor,
                                    fontSize: 22), // Aumenta el tamaño aquí
                              ),
                            ],
                          ),
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
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.print, size: 30),
                      onPressed: () {
                        // Imprimir el ticket de la orden seleccionada
                        _printOrder(order);
                      },
                    ),
                  ],
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
