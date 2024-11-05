import 'package:flutter/material.dart';
import 'package:restaurante/src/domain/models/Order.dart';
import 'package:restaurante/src/domain/models/OrderItem.dart';

class PizzaPreparationPendingCounter extends StatefulWidget {
  final List<Order> orders;

  const PizzaPreparationPendingCounter({Key? key, required this.orders})
      : super(key: key);

  @override
  _PizzaPreparationPendingCounterState createState() =>
      _PizzaPreparationPendingCounterState();
}

class _PizzaPreparationPendingCounterState
    extends State<PizzaPreparationPendingCounter> {
  Map<String, int> _pizzaCounts = {};

  @override
  void initState() {
    super.initState();
    _updatePizzaCounts();
    _printOrders(); // Llamada al método para imprimir órdenes
  }

  @override
  void didUpdateWidget(covariant PizzaPreparationPendingCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.orders != oldWidget.orders) {
      _updatePizzaCounts();
      _printOrders(); // Llamada al método para imprimir órdenes
    }
  }

  void _updatePizzaCounts() {
    Map<String, int> pizzaCounts = {};
    widget.orders
        .expand((order) => order.orderItems ?? [])
        .where((item) =>
            item.product?.subcategory?.name == 'Pizzas' &&
            item.status == OrderItemStatus.created)
        .forEach((item) {
      final name = item.productVariant?.shortName ??
          item.product?.shortName ??
          'Producto desconocido';
      pizzaCounts[name] = (pizzaCounts[name] ?? 0) + 1;
    });

    // Ordenar el mapa por clave (nombre de la pizza)
    var sortedPizzaCounts = Map.fromEntries(
      pizzaCounts.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key)),
    );

    setState(() {
      _pizzaCounts = sortedPizzaCounts;
    });
  }

  void _printOrders() {
    for (var order in widget.orders) {
      print('Order ID: ${order.id}');
      for (var item in order.orderItems ?? []) {
        print(
            '  Item: ${item.product?.shortName} , Subcategory: ${item.product?.subcategory} , Status: ${item.status}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.20,
      height: 270,
      decoration: BoxDecoration(
        //color: Colors.red.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pendientes de preparar',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
          ),
          SizedBox(height: 4.0),
          Expanded(
            child: ListView(
              children: _pizzaCounts.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${entry.key} ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17.0,
                          ),
                        ),
                        TextSpan(
                          text: '- ${entry.value}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
