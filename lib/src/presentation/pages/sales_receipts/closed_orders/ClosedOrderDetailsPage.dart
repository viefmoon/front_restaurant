import 'package:restaurante/src/domain/models/Order.dart';
import 'package:restaurante/src/domain/models/OrderAdjustment.dart';
import 'package:restaurante/src/domain/models/OrderItem.dart';
import 'package:restaurante/src/domain/models/SelectedPizzaIngredient.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClosedOrderDetailsPage extends StatefulWidget {
  final Order order;

  ClosedOrderDetailsPage({required this.order});

  @override
  _ClosedOrderDetailsPageState createState() => _ClosedOrderDetailsPageState();
}

class _ClosedOrderDetailsPageState extends State<ClosedOrderDetailsPage> {
  BluetoothDevice? _selectedPrinter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orden #${widget.order.id}'),
        actions: [
          IconButton(
            icon: Icon(Icons.print, size: 30),
            onPressed: () => _selectAndPrintTicket(context, widget.order),
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildOrderDetails(widget.order),
          _buildOrderItems(widget.order.orderItems),
          _buildOrderAdjustments(widget.order.orderAdjustments),
          _buildTotalWidget(widget.order),
        ],
      ),
    );
  }

  Widget _buildOrderDetails(Order order) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tipo de Pedido: ${order.orderType != null ? _getOrderTypeText(order.orderType!) : 'Desconocido'}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          _buildOrderTypeDetails(order),
          SizedBox(height: 8),
          Text(
            'Fecha creacion: ${DateFormat('yyyy-MM-dd HH:mm').format(order.creationDate!.toLocal())}',
            style: TextStyle(fontSize: 16),
          ),
          Text(
            'Fecha finalizacion: ${DateFormat('yyyy-MM-dd HH:mm').format(order.completionDate!.toLocal())}',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Estado: ${_getOrderStatusText(order.status)}',
            style: TextStyle(
                fontSize: 16, color: _getOrderStatusColor(order.status)),
          ),
          SizedBox(height: 8),
          if (order.comments != null && order.comments!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Comentarios:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  order.comments!,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildOrderTypeDetails(Order order) {
    switch (order.orderType) {
      case OrderType.delivery:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Telefono: ${order.phoneNumber}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 4),
            Text(
              'Dirección: ${order.deliveryAddress}',
              style: TextStyle(fontSize: 16),
            ),
          ],
        );
      case OrderType.dineIn:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Area: ${order.area?.name}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 4),
            Text(
              'Mesa: ${order.table?.number ?? order.table?.temporaryIdentifier}',
              style: TextStyle(fontSize: 16),
            ),
          ],
        );
      case OrderType.pickUpWait:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nombre del Cliente: ${order.customerName}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 4),
            Text(
              'Telefono: ${order.phoneNumber}',
              style: TextStyle(fontSize: 16),
            ),
          ],
        );
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildOrderItems(List<OrderItem>? orderItems) {
    if (orderItems == null || orderItems.isEmpty) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Productos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          ...orderItems.map((item) => _buildOrderItemWidget(item)).toList(),
        ],
      ),
    );
  }

  Widget _buildOrderItemWidget(OrderItem item) {
    List<Widget> details = [];

    if (item.productVariant != null) {
      details.add(Text(
        'Variante: ${item.productVariant?.name}',
        style: TextStyle(fontSize: 16),
      ));
    }
    if (item.selectedModifiers != null && item.selectedModifiers!.isNotEmpty) {
      details.add(Text(
        'Modificadores: ${item.selectedModifiers!.map((m) => m.modifier?.name).join(', ')}',
        style: TextStyle(fontSize: 16),
      ));
    }
    if (item.selectedPizzaFlavors != null &&
        item.selectedPizzaFlavors!.isNotEmpty) {
      details.add(Text(
        'Sabor: ${item.selectedPizzaFlavors!.map((f) => f.pizzaFlavor?.name).join('/')}',
        style: TextStyle(fontSize: 16),
      ));
    }
    if (item.selectedPizzaIngredients != null &&
        item.selectedPizzaIngredients!.isNotEmpty) {
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

      String ingredientsText = '';
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

      details.add(Text(
        'Ingredientes: $ingredientsText',
        style: TextStyle(fontSize: 16),
      ));
    }
    if (item.selectedProductObservations != null &&
        item.selectedProductObservations!.isNotEmpty) {
      details.add(Text(
        'Observaciones: ${item.selectedProductObservations!.map((o) => o.productObservation?.name).join(', ')}',
        style: TextStyle(fontSize: 16),
      ));
    }
    if (item.comments != null && item.comments!.isNotEmpty) {
      details.add(Text(
        'Comentarios: ${item.comments}',
        style: TextStyle(fontSize: 16),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.product?.name ?? '',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              '\$${item.price?.toStringAsFixed(2) ?? ''}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        ...details,
        SizedBox(height: 8),
      ],
    );
  }

  Widget _buildOrderAdjustments(List<OrderAdjustment>? orderAdjustments) {
    if (orderAdjustments == null || orderAdjustments.isEmpty) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ajustes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          ...orderAdjustments
              .map((adjustment) => _buildOrderAdjustmentWidget(adjustment))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildOrderAdjustmentWidget(OrderAdjustment adjustment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            adjustment.name ?? '',
            style: TextStyle(fontSize: 16),
          ),
          Text(
            adjustment.amount! < 0
                ? '-\$${(-adjustment.amount!).toStringAsFixed(2)}'
                : '\$${adjustment.amount?.toStringAsFixed(2) ?? ''}',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalWidget(Order order) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'Total: \$${order.totalCost?.toStringAsFixed(2) ?? ''}',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          if (order.amountPaid != null && order.amountPaid! > 0)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Total Pagado: \$${order.amountPaid!.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Restante: \$${(order.totalCost! - order.amountPaid!).toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _getOrderTypeText(OrderType orderType) {
    switch (orderType) {
      case OrderType.delivery:
        return 'Entrega a domicilio';
      case OrderType.dineIn:
        return 'Comer Dentro';
      case OrderType.pickUpWait:
        return 'Llevar/Esperar';
      default:
        return 'Desconocido';
    }
  }

  String _getOrderStatusText(OrderStatus? status) {
    switch (status) {
      case OrderStatus.canceled:
        return 'Cancelado';
      case OrderStatus.finished:
        return 'Finalizado';
      default:
        return 'Desconocido';
    }
  }

  Color _getOrderStatusColor(OrderStatus? status) {
    switch (status) {
      case OrderStatus.canceled:
        return Colors.red;
      case OrderStatus.finished:
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  Future<void> _selectAndPrintTicket(BuildContext context, Order order) async {
    BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

    // Verificar si ya está conectado y desconectar si es necesario
    bool? isConnected = await bluetooth.isConnected;
    if (isConnected != null && isConnected) {
      await bluetooth.disconnect();
    }

    List<BluetoothDevice> devices = await bluetooth.getBondedDevices();
    if (devices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se encontraron impresoras Bluetooth.'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    BluetoothDevice? selectedDevice = await showDialog<BluetoothDevice>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Seleccionar impresora'),
          content: SingleChildScrollView(
            child: ListBody(
              children: devices
                  .map((device) => RadioListTile(
                        title: Text(device.name ?? ''),
                        value: device,
                        groupValue: _selectedPrinter,
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
      setState(() {
        _selectedPrinter = selectedDevice;
      });

      try {
        if (await bluetooth.isConnected ?? false) {
          await bluetooth.disconnect();
        }

        await bluetooth.connect(_selectedPrinter!);
        await Future.delayed(Duration(milliseconds: 500));

        String ticketContent = _generateTicketContent(order);
        await bluetooth.printCustom(ticketContent, 0, 1);
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

  String _generateTicketContent(Order order) {
    String content = '';
    String cmdFontSizeLarge =
        "\x1d\x21\x12"; // Ajusta este valor según tu impresora
    String cmdFontSizeMedium = "\x1d\x21\x01"; // Tamaño de fuente intermedio
    String cmdFontSizeNormal =
        "\x1d\x21\x00"; // Comando para restablecer el tamaño de la fuente a normal

    // Comandos para activar/desactivar negrita
    String cmdBoldOn = "\x1b\x45\x01";
    String cmdBoldOff = "\x1b\x45\x00";

    // Comando para alinear el texto a la izquierda
    String cmdAlignLeft = "\x1b\x61\x00";

    // Comando para centrar el texto
    String cmdAlignCenter = "\x1b\x61\x01";

    // Añadir "Orden" con el tamaño de fuente grande y en negrita
    content += cmdBoldOn +
        cmdFontSizeLarge +
        'Orden #${order.id}\n\n' +
        cmdBoldOff +
        cmdFontSizeNormal;

    // Imprimir el tipo de orden con un tamaño de fuente intermedio y en negritas, sin la etiqueta "Tipo:", alineado a la izquierda
    content += cmdFontSizeMedium +
        '${order.orderType != null ? _getOrderTypeText(order.orderType!) : 'Desconocido'}\n' +
        cmdBoldOff +
        cmdFontSizeNormal;

    // Alinear los detalles de la orden a la izquierda
    content += cmdAlignLeft;

    // Agregar detalles específicos según el tipo de orden
    switch (order.orderType) {
      case OrderType.delivery:
        content += cmdFontSizeMedium +
            'Telefono: ${order.phoneNumber}\n' +
            cmdFontSizeNormal;
        content += cmdFontSizeMedium +
            'Direccion: ${removeAccents(order.deliveryAddress ?? '')}\n' +
            cmdFontSizeNormal;
        break;
      case OrderType.dineIn:
        content += cmdFontSizeMedium +
            'Area: ${order.area?.name}\n' +
            cmdFontSizeNormal;
        content += cmdFontSizeMedium +
            'Mesa: ${order.table?.number}\n' +
            cmdFontSizeNormal;
        break;
      case OrderType.pickUpWait:
        content += cmdFontSizeMedium +
            'Nombre del Cliente: ${order.customerName}\n' +
            cmdFontSizeNormal;
        content += cmdFontSizeMedium +
            'Telefono: ${order.phoneNumber}\n' +
            cmdFontSizeNormal;
        break;
      default:
        break;
    }

    // Añadir la fecha de impresión del ticket formateada hasta el minuto
    content += 'Fecha: ${DateTime.now().toString().substring(0, 16)}\n';
    content +=
        '--------------------------------\n'; // Línea de separación con guiones

    // Imprimir los detalles de los productos
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
    });

    // Procesar los ajustes de la orden
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

    content += cmdFontSizeLarge +
        'Total: \$${order.totalCost?.toStringAsFixed(2) ?? ''}\n' +
        cmdFontSizeNormal; // Restablece el tamaño de la fuente a normal después del total

    // Añade un mensaje de gracias después del total
    content += cmdAlignCenter +
        cmdFontSizeMedium +
        '\n" Gracias "\n' +
        cmdFontSizeNormal;

    // Restablece la alineación a la izquierda después del mensaje de gracias
    content += cmdAlignLeft;

    content += '\n\n';
    return content;
  }

  String removeAccents(String originalString) {
    const accents = 'ÀÁÂÃÄÅàáâãäåÒÓÔÕÖØòóôõöøÈÉÊËèéêëÇçÌÍÎÏìíîïÙÚÛÜùúûüÿÑñ';
    const withoutAccents =
        'AAAAAAaaaaaaOOOOOOooooooEEEEeeeeCcIIIIiiiiUUUUuuuuyNn';

    String result = '';
    for (int i = 0; i < originalString.length; i++) {
      final char = originalString[i];
      final index = accents.indexOf(char);
      if (index != -1) {
        result += withoutAccents[index];
      } else {
        result += char;
      }
    }
    return result;
  }
}
