import 'package:restaurante/src/domain/models/Order.dart';
import 'package:restaurante/src/domain/models/OrderItem.dart';
import 'package:restaurante/src/domain/models/SelectedModifier.dart';
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
  bool filterDelivery = false;
  bool filterPickUpWait = false;

  @override
  void initState() {
    super.initState();
    final DeliveryOrdersBloc bloc =
        BlocProvider.of<DeliveryOrdersBloc>(context, listen: false);
    bloc.add(LoadDeliveryOrders());
  }

  double getTotalCostOfSelectedOrders() {
    return selectedOrders.fold(0.0, (sum, order) {
      double remainingAmount =
          (order.totalCost ?? 0.0) - (order.amountPaid ?? 0.0);
      return sum + (remainingAmount > 0 ? remainingAmount : 0.0);
    });
  }

  List<Order> _filterOrders(List<Order> orders) {
    if (filterDelivery) {
      return orders
          .where((order) => order.orderType == OrderType.delivery)
          .toList();
    } else if (filterPickUpWait) {
      return orders
          .where((order) => order.orderType == OrderType.pickUpWait)
          .toList();
    }
    return orders;
  }

  String _generateTicketContent(Order order) {
    String content = '';
    String cmdFontSizeLarge =
        "\x1d\x21\x12"; // Ajusta este valor según tu impresora
    String cmdFontSizeMedium = "\x1d\x21\x01";
    String cmdFontSizeNormal =
        "\x1d\x21\x00"; // Comando para restablecer el tamaño de la fuente a normal

    // Comandos para activar/desactivar negrita
    String cmdBoldOn = "\x1b\x45\x01";
    String cmdBoldOff = "\x1b\x45\x00";

    // Comando para centrar el texto
    String cmdAlignCenter = "\x1b\x61\x01";

    // Comando para alinear el texto a la izquierda
    String cmdAlignLeft = "\x1b\x61\x00";

    // Añadir "Orden" con el tamaño de fuente grande y en negrita
    content += cmdBoldOn +
        cmdFontSizeLarge +
        'Orden #${order.id}\n\n' +
        cmdBoldOff +
        cmdFontSizeMedium;

    // Imprimir el tipo de orden
    switch (order.orderType) {
      case OrderType.delivery:
        content += cmdAlignCenter + 'Entrega a domicilio\n\n';
        break;
      case OrderType.dineIn:
        content += cmdAlignCenter + 'Comer Dentro\n\n';
        break;
      case OrderType.pickUpWait:
        content += cmdAlignCenter + 'Llevar/Esperar\n\n';
        break;
      default:
        content += cmdAlignCenter + 'Tipo de orden desconocido\n\n';
        break;
    }

    // Alinear los detalles de la orden a la izquierda
    content += cmdAlignLeft;

    // Imprimir detalles de la orden
    switch (order.orderType) {
      case OrderType.delivery:
        content += 'Telefono: ${order.phoneNumber}\n';
        content += 'Direccion: ${order.deliveryAddress}\n' + cmdFontSizeNormal;
        break;
      case OrderType.dineIn:
        content += 'Area: ${order.area?.name}\n';
        content += 'Mesa: ${order.table?.number}\n' + cmdFontSizeNormal;
        break;
      case OrderType.pickUpWait:
        content += 'Nombre del Cliente: ${order.customerName}\n';
        content += 'Telefono: ${order.phoneNumber}\n' + cmdFontSizeNormal;
        break;
      default:
        break;
    }

    // Añadir la fecha de impresión del ticket formateada hasta el minuto
    content += 'Fecha: ${DateTime.now().toString().substring(0, 16)}\n';
    content +=
        '--------------------------------\n'; // Línea de separación con guiones

    // Imprimir los detalles de los productos de la orden
    order.orderItems?.forEach((item) {
      final int lineWidth = 32; // Ajusta según el ancho de tu impresora
      String productName =
          item.productVariant?.name ?? item.product?.name ?? '';
      String productPrice = '\$${item.price?.toStringAsFixed(2) ?? ''}';

      // Calcula el espacio máximo disponible para el nombre del producto o variante
      int maxProductNameLength = lineWidth - productPrice.length - 1;

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
          ingredientsText += ingredientsLeft;
        }
        if (ingredientsRight.isNotEmpty) {
          if (ingredientsText.isNotEmpty) ingredientsText += ' / ';
          ingredientsText += ingredientsRight;
        }
        if (ingredientsNone.isNotEmpty) {
          if (ingredientsText.isNotEmpty) ingredientsText += ' | ';
          ingredientsText += '$ingredientsNone';
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
    content += cmdAlignCenter +
        cmdFontSizeMedium +
        '\n" Gracias por su preferencia "\n';

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
          if (selectedOrders.isNotEmpty)
            IconButton(
              icon: Icon(Icons.check_circle, size: 40),
              onPressed: () async {
                // Verificar si alguna de las órdenes seleccionadas no está en estado 'Preparado'
                bool hasUnpreparedOrders = selectedOrders
                    .any((order) => order.status != OrderStatus.prepared);
                if (hasUnpreparedOrders) {
                  // Mostrar diálogo de confirmación
                  bool confirm = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Confirmar acción',
                                style: TextStyle(fontSize: 24)),
                            content: Text(
                                'Algunas de las órdenes seleccionadas no están preparadas. ¿Desea continuar?',
                                style: TextStyle(fontSize: 20)),
                            actions: <Widget>[
                              TextButton(
                                child:
                                    Text('No', style: TextStyle(fontSize: 22)),
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(false); // No continuar
                                },
                              ),
                              TextButton(
                                child:
                                    Text('Sí', style: TextStyle(fontSize: 22)),
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(true); // Sí continuar
                                },
                              ),
                            ],
                          );
                        },
                      ) ??
                      false; // Asumir 'No' si se cierra el diálogo

                  if (!confirm)
                    return; // Si el usuario no confirma, detener la acción
                }

                // Proceder con la acción original si todas las órdenes están preparadas o el usuario confirmó
                if (selectedOrders.isNotEmpty) {
                  bloc.add(MarkOrdersAsDelivered(List.from(selectedOrders)));
                  setState(() {
                    selectedOrders.clear();
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'No hay órdenes seleccionadas para marcar como entregadas.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: Center(
              child: Text(
                'Total: \$${totalCost.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 26),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          CheckboxListTile(
            title: Text('Filtrar a Domicilio', style: TextStyle(fontSize: 24)),
            value: filterDelivery,
            onChanged: (bool? value) {
              setState(() {
                filterDelivery = value!;
                filterPickUpWait = false;
              });
            },
          ),
          CheckboxListTile(
            title:
                Text('Filtrar Pasan/Esperan', style: TextStyle(fontSize: 24)),
            value: filterPickUpWait,
            onChanged: (bool? value) {
              setState(() {
                filterPickUpWait = value!;
                filterDelivery = false;
              });
            },
          ),
          Expanded(
            child: BlocConsumer<DeliveryOrdersBloc, DeliveryOrdersState>(
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
                  List<Order> filteredOrders = _filterOrders(state.orders!);
                  return ListView.builder(
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      String statusText;
                      Color textColor;
                      Color paymentStatusColor;
                      switch (order.status) {
                        case OrderStatus.created:
                          statusText = 'Creado';
                          textColor = Colors.blue;
                          paymentStatusColor = order.amountPaid != null &&
                                  order.totalCost != null &&
                                  order.amountPaid! >= order.totalCost!
                              ? Colors.green
                              : Colors.red;
                          break;
                        case OrderStatus.prepared:
                          statusText = 'Preparado';
                          textColor = Colors.green;
                          paymentStatusColor = order.amountPaid != null &&
                                  order.totalCost != null &&
                                  order.amountPaid! >= order.totalCost!
                              ? Colors.green
                              : Colors.red;
                          break;
                        case OrderStatus.in_preparation:
                          statusText = 'En preparacion';
                          textColor = Color.fromARGB(255, 221, 204, 75);
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

                      // Determine the display text based on the order type
                      String displayText;
                      if (order.orderType == OrderType.pickUpWait) {
                        displayText =
                            '#${order.id} - ${order.customerName}, Tel: ${order.phoneNumber}';
                      } else {
                        displayText =
                            '#${order.id} - ${order.deliveryAddress}, Tel: ${order.phoneNumber}';
                      }

                      bool containsBeverage = order.orderItems?.any((item) =>
                              item.product?.subcategory?.category?.name ==
                              'Bebida') ??
                          false;

                      return Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: SingleChildScrollView(
                                        child: ListBody(
                                          children: _groupOrderItems(
                                                  order.orderItems!)
                                              .entries
                                              .map((entry) {
                                            final item = entry.key;
                                            final count = entry.value;
                                            String itemName =
                                                item.productVariant?.name ??
                                                    item.product?.name ??
                                                    '';
                                            if (item.selectedModifiers !=
                                                    null &&
                                                item.selectedModifiers!
                                                    .isNotEmpty) {
                                              String modifiers = item
                                                  .selectedModifiers!
                                                  .map((m) => m.modifier?.name)
                                                  .join(', ');
                                              itemName += ' ($modifiers)';
                                            }
                                            String displayText = count > 1
                                                ? '$count - $itemName'
                                                : itemName;
                                            return Text(
                                              displayText,
                                              style: TextStyle(fontSize: 22),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text('Cerrar',
                                              style: TextStyle(
                                                  fontSize:
                                                      22)), // Increased font size
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0, vertical: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      displayText,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 22,
                                      ),
                                    ),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text:
                                                'Total: \$${order.totalCost?.toStringAsFixed(2) ?? ''} - ${order.creationDate != null ? '${order.creationDate!.toLocal().hour}:${order.creationDate!.toLocal().minute}' : ''} -  $statusText',
                                            style: TextStyle(
                                              color: textColor,
                                              fontSize: 17,
                                            ),
                                          ),
                                          TextSpan(
                                            text: order.amountPaid != null &&
                                                    order.totalCost != null &&
                                                    order.amountPaid! >=
                                                        order.totalCost!
                                                ? ' (PAGADO)'
                                                : ' (NO PAGADO)',
                                            style: TextStyle(
                                              color: paymentStatusColor,
                                              fontSize: 16,
                                            ),
                                          ),
                                          if (containsBeverage)
                                            TextSpan(
                                              text: ' BEBIDA',
                                              style: TextStyle(
                                                fontSize: 17,
                                              ),
                                            )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Transform.scale(
                            scale:
                                1.8, // Ajusta este valor para cambiar el tamaño del Checkbox
                            child: Checkbox(
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
                              activeColor: Color.fromARGB(255, 255, 255, 255),
                              checkColor: const Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                          SizedBox(width: 20), // Added a SizedBox for spacing
                          IconButton(
                            icon: Icon(Icons.print, size: 40),
                            onPressed: () {
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
                      child: Text(
                          'No hay pedidos para llevar listos para entrega.'));
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10.0, right: 10.0),
        child: SizedBox(
          width: 65,
          height: 65,
          child: FloatingActionButton(
            onPressed: () {
              setState(() {
                selectedOrders.clear();
              });

              bloc.add(LoadDeliveryOrders());
            },
            child: Icon(Icons.refresh, size: 40),
            backgroundColor: Colors.blue,
          ),
        ),
      ),
    );
  }

  Map<OrderItem, int> _groupOrderItems(List<OrderItem> items) {
    final Map<OrderItem, int> groupedItems = {};
    for (var item in items) {
      bool found = false;
      for (var key in groupedItems.keys) {
        if (_areItemsEqual(key, item)) {
          groupedItems[key] = groupedItems[key]! + 1;
          found = true;
          break;
        }
      }
      if (!found) {
        groupedItems[item] = 1;
      }
    }
    return groupedItems;
  }

  bool _areItemsEqual(OrderItem a, OrderItem b) {
    return a.productVariant?.id == b.productVariant?.id &&
        a.product?.id == b.product?.id &&
        _areModifiersEqual(a.selectedModifiers, b.selectedModifiers);
  }

  bool _areModifiersEqual(
      List<SelectedModifier>? a, List<SelectedModifier>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (var modifier in a) {
      if (!b.any((m) => m.modifier?.id == modifier.modifier?.id)) {
        return false;
      }
    }
    return true;
  }
}
