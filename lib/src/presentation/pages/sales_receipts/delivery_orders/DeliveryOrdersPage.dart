import 'dart:typed_data';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:intl/intl.dart';
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

  String _removeAccents(String input) {
    const accents = 'áéíóúÁÉÍÓÚñÑ';
    const withoutAccents = 'aeiouAEIOUnN';
    String output = input;
    for (int i = 0; i < accents.length; i++) {
      output = output.replaceAll(accents[i], withoutAccents[i]);
    }
    return output;
  }

  Future<List<int>> _generateTicketContent80(Order order) async {
    final profile = await CapabilityProfile.load(name: 'default');
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];
    bytes += generator.setGlobalCodeTable('CP1252');
    // Añadir "Orden" con el tamaño de fuente grande y en negrita
    bytes += generator.text(
      _removeAccents('Orden #${order.id}'),
      styles: PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size3,
        width: PosTextSize.size3,
        bold: true,
        fontType: PosFontType.fontA,
      ),
    );

    // Añadir un salto de línea
    bytes += generator.feed(1);

    // Imprimir detalles de la orden
    switch (order.orderType) {
      case OrderType.delivery:
        bytes += generator.text(
            _removeAccents('Telefono: ${order.phoneNumber}'),
            styles: PosStyles(
                height: PosTextSize.size2,
                width: PosTextSize.size2,
                bold: true));
        bytes += generator.text(
            _removeAccents('Direccion: ${order.deliveryAddress}'),
            styles: PosStyles(
                height: PosTextSize.size2,
                width: PosTextSize.size2,
                bold: true));
        break;
      case OrderType.pickUpWait:
        bytes += generator.text(
            _removeAccents('Nombre del Cliente: ${order.customerName}'),
            styles: PosStyles(
                height: PosTextSize.size2,
                width: PosTextSize.size2,
                bold: true));
        bytes += generator.text(
            _removeAccents('Telefono: ${order.phoneNumber}'),
            styles: PosStyles(
                height: PosTextSize.size2,
                width: PosTextSize.size2,
                bold: true));
        break;
      default:
        break;
    }

    if (order.comments != null && order.comments!.isNotEmpty) {
      bytes += generator.text(
        _removeAccents('Comentarios: ${order.comments}'),
        styles: PosStyles(
          align: PosAlign.left,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          bold: true,
        ),
      );
    }

    // Añadir la fecha de creación del ticket formateada hasta el minuto en hora local
    String formattedCreationDate =
        DateFormat('dd/MM/yyyy HH:mm').format(order.creationDate!.toLocal());
    bytes += generator.text('Fecha: $formattedCreationDate',
        styles: PosStyles(
          align: PosAlign.left,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ));

    bytes += generator.hr();

    // Imprimir los detalles de los productos de la orden
    order.orderItems?.forEach((item) {
      String productName =
          _removeAccents(item.productVariant?.name ?? item.product?.name ?? '');
      String productPrice = '\$${item.price?.toInt() ?? ''}';

      bytes += generator.row([
        PosColumn(
          text: productName,
          width: 9,
          styles: PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size3,
            width: PosTextSize.size2,
          ),
        ),
        PosColumn(
          text: productPrice,
          width: 3,
          styles: PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          ),
        ),
      ]);

      // Agrega detalles adicionales como modificadores, ingredientes, etc.
      if (item.selectedModifiers != null &&
          item.selectedModifiers!.isNotEmpty) {
        String modifiersText = _removeAccents(
            '${item.selectedModifiers!.map((m) => m.modifier?.name).join(', ')}');
        bytes += generator.text(modifiersText,
            styles: PosStyles(
              align: PosAlign.left,
              height: PosTextSize.size2,
            ));
      }
      if (item.selectedProductObservations != null &&
          item.selectedProductObservations!.isNotEmpty) {
        String modifiersText = _removeAccents(
            '${item.selectedProductObservations!.map((m) => m.productObservation?.name).join(', ')}');
        bytes += generator.text(modifiersText,
            styles: PosStyles(
              align: PosAlign.left,
              height: PosTextSize.size2,
            ));
      }
      if (item.selectedPizzaFlavors != null &&
          item.selectedPizzaFlavors!.isNotEmpty) {
        String flavorsText = _removeAccents(
            '${item.selectedPizzaFlavors!.map((f) => f.pizzaFlavor?.name).join('/')}');
        bytes += generator.text(flavorsText,
            styles: PosStyles(
              align: PosAlign.left,
              height: PosTextSize.size2, // Aumenta el tamaño del texto
            ));
      }
      if (item.selectedPizzaIngredients != null &&
          item.selectedPizzaIngredients!.isNotEmpty) {
        String ingredientsText = '';
        final ingredientsLeft = _removeAccents(item.selectedPizzaIngredients!
            .where((i) => i.half == PizzaHalf.left)
            .map((i) => i.pizzaIngredient?.name)
            .join(', '));
        final ingredientsRight = _removeAccents(item.selectedPizzaIngredients!
            .where((i) => i.half == PizzaHalf.right)
            .map((i) => i.pizzaIngredient?.name)
            .join(', '));
        final ingredientsNone = _removeAccents(item.selectedPizzaIngredients!
            .where((i) => i.half == PizzaHalf.none)
            .map((i) => i.pizzaIngredient?.name)
            .join(', '));
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
        bytes += generator.text(ingredientsText,
            styles: PosStyles(
              align: PosAlign.left,
              height: PosTextSize.size2, // Aumenta el tamaño del texto
            ));
      }
      if (item.comments != null && item.comments!.isNotEmpty) {
        String commentsText = _removeAccents('${item.comments}');
        bytes += generator.text(commentsText,
            styles: PosStyles(
              align: PosAlign.left,
              height: PosTextSize.size2, // Aumenta el tamaño del texto
            ));
      }
    });

    // Procesamiento de los ajustes de la orden
    order.orderAdjustments?.forEach((adjustment) {
      String adjustmentName = _removeAccents(adjustment.name ?? '');
      String adjustmentAmount = adjustment.amount! < 0
          ? '-\$${(-adjustment.amount!).toInt()}'
          : '\$${adjustment.amount?.toInt() ?? ''}';

      bytes += generator.row([
        PosColumn(
          text: adjustmentName,
          width: 9,
          styles: PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: adjustmentAmount,
          width: 3,
          styles: PosStyles(align: PosAlign.right),
        ),
      ]);
    });

    bytes += generator.hr(); // Línea de separación
    bytes += generator.text(
      'Total: \$${order.totalCost?.toInt()}',
      styles: PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );

    // Verifica si hay un pago registrado
    if (order.amountPaid != null && order.amountPaid! > 0) {
      bytes += generator.text(
        'Pagado: \$${order.amountPaid?.toStringAsFixed(2)}',
        styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );
      bytes += generator.text(
        'Resto: \$${(order.totalCost! - order.amountPaid!).toStringAsFixed(2)}',
        styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );
    }

    // Añade un mensaje de gracias después del total
    bytes += generator.text(
      _removeAccents('\n" Gracias por su preferencia "'),
      styles: PosStyles(align: PosAlign.center),
    );

    // Añade el corte de papel al final
    bytes += generator.cut();

    return bytes;
  }

  Future<List<int>> _generateTicketContent58(Order order) async {
    final profile = await CapabilityProfile.load(name: 'default');
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];
    bytes += generator.setGlobalCodeTable('CP1252');
    // Añadir "Orden" con el tamaño de fuente grande y en negrita
    bytes += generator.text(
      _removeAccents('Orden #${order.id}'),
      styles: PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size3,
        width: PosTextSize.size2,
        bold: true,
        fontType: PosFontType.fontA,
      ),
    );

    // Añadir un salto de línea
    bytes += generator.feed(1);

    // Imprimir detalles de la orden
    switch (order.orderType) {
      case OrderType.delivery:
        bytes += generator.text(
            _removeAccents('Telefono: ${order.phoneNumber}'),
            styles: PosStyles(
                height: PosTextSize.size2,
                width: PosTextSize.size1,
                bold: true));
        bytes += generator.text(
            _removeAccents('Direccion: ${order.deliveryAddress}'),
            styles: PosStyles(
                height: PosTextSize.size2,
                width: PosTextSize.size1,
                bold: true));
        break;
      case OrderType.pickUpWait:
        bytes += generator.text(
            _removeAccents('Nombre del Cliente: ${order.customerName}'),
            styles: PosStyles(
                height: PosTextSize.size2,
                width: PosTextSize.size1,
                bold: true));
        bytes += generator.text(
            _removeAccents('Telefono: ${order.phoneNumber}'),
            styles: PosStyles(
                height: PosTextSize.size2,
                width: PosTextSize.size1,
                bold: true));
        break;
      default:
        break;
    }

    if (order.comments != null && order.comments!.isNotEmpty) {
      bytes += generator.text(
        _removeAccents('Comentarios: ${order.comments}'),
        styles: PosStyles(
          align: PosAlign.left,
          height: PosTextSize.size2,
          width: PosTextSize.size1,
          bold: true,
        ),
      );
    }

    // Añadir la fecha de creación del ticket formateada hasta el minuto
    String formattedCreationDate =
        DateFormat('dd/MM/yyyy HH:mm').format(order.creationDate!.toLocal());
    bytes += generator.text('Fecha: $formattedCreationDate',
        styles: PosStyles(
          align: PosAlign.left,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ));

    bytes += generator.hr();

    // Imprimir los detalles de los productos de la orden
    order.orderItems?.forEach((item) {
      String productName =
          _removeAccents(item.productVariant?.name ?? item.product?.name ?? '');
      String productPrice = '\$${item.price?.toInt() ?? ''}';

      bytes += generator.row([
        PosColumn(
          text: productName,
          width: 9,
          styles: PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size2,
            width: PosTextSize.size1,
          ),
        ),
        PosColumn(
          text: productPrice,
          width: 3,
          styles: PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          ),
        ),
      ]);

      // Agrega detalles adicionales como modificadores, ingredientes, etc.
      if (item.selectedModifiers != null &&
          item.selectedModifiers!.isNotEmpty) {
        String modifiersText = _removeAccents(
            '${item.selectedModifiers!.map((m) => m.modifier?.name).join(', ')}');
        bytes += generator.text(modifiersText,
            styles: PosStyles(
              align: PosAlign.left,
              height: PosTextSize.size1,
            ));
      }
      if (item.selectedProductObservations != null &&
          item.selectedProductObservations!.isNotEmpty) {
        String modifiersText = _removeAccents(
            '${item.selectedProductObservations!.map((m) => m.productObservation?.name).join(', ')}');
        bytes += generator.text(modifiersText,
            styles: PosStyles(
              align: PosAlign.left,
              height: PosTextSize.size1,
            ));
      }
      if (item.selectedPizzaFlavors != null &&
          item.selectedPizzaFlavors!.isNotEmpty) {
        String flavorsText = _removeAccents(
            '${item.selectedPizzaFlavors!.map((f) => f.pizzaFlavor?.name).join('/')}');
        bytes += generator.text(flavorsText,
            styles: PosStyles(
              align: PosAlign.left,
              height: PosTextSize.size1, // Aumenta el tamaño del texto
            ));
      }
      if (item.selectedPizzaIngredients != null &&
          item.selectedPizzaIngredients!.isNotEmpty) {
        String ingredientsText = '';
        final ingredientsLeft = _removeAccents(item.selectedPizzaIngredients!
            .where((i) => i.half == PizzaHalf.left)
            .map((i) => i.pizzaIngredient?.name)
            .join(', '));
        final ingredientsRight = _removeAccents(item.selectedPizzaIngredients!
            .where((i) => i.half == PizzaHalf.right)
            .map((i) => i.pizzaIngredient?.name)
            .join(', '));
        final ingredientsNone = _removeAccents(item.selectedPizzaIngredients!
            .where((i) => i.half == PizzaHalf.none)
            .map((i) => i.pizzaIngredient?.name)
            .join(', '));
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
        bytes += generator.text(ingredientsText,
            styles: PosStyles(
              align: PosAlign.left,
              height: PosTextSize.size1, // Aumenta el tamaño del texto
            ));
      }
      if (item.comments != null && item.comments!.isNotEmpty) {
        String commentsText = _removeAccents('${item.comments}');
        bytes += generator.text(commentsText,
            styles: PosStyles(
              align: PosAlign.left,
              height: PosTextSize.size1, // Aumenta el tamaño del texto
            ));
      }
    });

    // Procesamiento de los ajustes de la orden
    order.orderAdjustments?.forEach((adjustment) {
      String adjustmentName = _removeAccents(adjustment.name ?? '');
      String adjustmentAmount = adjustment.amount! < 0
          ? '-\$${(-adjustment.amount!).toInt()}'
          : '\$${adjustment.amount?.toInt() ?? ''}';

      bytes += generator.row([
        PosColumn(
          text: adjustmentName,
          width: 9,
          styles: PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: adjustmentAmount,
          width: 3,
          styles: PosStyles(align: PosAlign.right),
        ),
      ]);
    });

    bytes += generator.hr(); // Línea de separación
    bytes += generator.text(
      'Total: \$${order.totalCost?.toInt()}',
      styles: PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size3,
        width: PosTextSize.size2,
      ),
    );
    if (order.amountPaid != null && order.amountPaid! > 0) {
      bytes += generator.text(
        'Pagado: \$${order.amountPaid?.toStringAsFixed(2)}',
        styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );
      bytes += generator.text(
        'Resto: \$${(order.totalCost! - order.amountPaid!).toStringAsFixed(2)}',
        styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );
    }

    // Añade un mensaje de gracias después del total
    bytes += generator.text(
      _removeAccents('\n" Gracias por su preferencia "\n'),
      styles: PosStyles(align: PosAlign.center),
    );

    bytes += generator.feed(2); // Avanza el papel tres líneas

    return bytes;
  }

  Future<void> _selectAndPrintTicket(Order order) async {
    BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
    const int maxRetries = 1;
    const Duration timeoutDuration = Duration(seconds: 3);

    // Verificar si ya está conectado y desconectar si es necesario
    bool? isConnected = await bluetooth.isConnected;
    if (isConnected != null && isConnected) {
      await bluetooth.disconnect();
      await Future.delayed(Duration(
          seconds: 1)); // Esperar un momento para asegurar la desconexión
    }

    // Obtener dispositivos emparejados
    List<BluetoothDevice> devices = await bluetooth.getBondedDevices();
    if (devices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se encontraron impresoras Bluetooth.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Muestra un diálogo para seleccionar la impresora y el tamaño del papel
    Map<String, dynamic>? selection = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        String selectedPaperSize = '80mm'; // Valor por defecto
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Seleccionar impresora y papel'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    ListBody(
                      children: devices
                          .map((device) => RadioListTile<BluetoothDevice>(
                                title: Text(device.name ?? ''),
                                value: device,
                                groupValue: null,
                                onChanged: (BluetoothDevice? value) {
                                  Navigator.pop(context, {
                                    'device': value,
                                    'paperSize': selectedPaperSize
                                  });
                                },
                              ))
                          .toList(),
                    ),
                    Divider(),
                    ListTile(
                      title: Text('Tamaño del papel'),
                      trailing: DropdownButton<String>(
                        value: selectedPaperSize,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedPaperSize = newValue!;
                          });
                        },
                        items: <String>['58mm', '80mm']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (selection != null) {
      BluetoothDevice? selectedDevice = selection['device'];
      String selectedPaperSize = selection['paperSize'];

      for (int attempt = 1; attempt <= maxRetries; attempt++) {
        try {
          // Verificar si ya está conectado y desconectar si es necesario
          isConnected = await bluetooth.isConnected;
          if (isConnected != null && isConnected) {
            await bluetooth.disconnect();
            await Future.delayed(Duration(
                seconds: 2)); // Esperar un momento para asegurar la desconexión
          }

          // Conectar con la impresora seleccionada
          if (selectedDevice != null) {
            await bluetooth.connect(selectedDevice).timeout(timeoutDuration);
          }

          // Generar el contenido del ticket segn el tamaño del papel seleccionado
          List<int> ticketContent;
          if (selectedPaperSize == '58mm') {
            ticketContent = await _generateTicketContent58(order);
          } else {
            ticketContent = await _generateTicketContent80(order);
          }

          // Imprimir el ticket
          await bluetooth.writeBytes(Uint8List.fromList(ticketContent));

          // Desconectar de la impresora
          await bluetooth.disconnect();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ticket impreso correctamente.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          return; // Salir de la función si la impresión fue exitosa
        } catch (e) {
          if (attempt == maxRetries) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al imprimir el ticket: $e'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      }
    }
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
                              _selectAndPrintTicket(order);
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
