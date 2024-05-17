import 'package:flutter/material.dart';
import 'package:restaurante/src/domain/models/Order.dart';
import 'package:restaurante/src/domain/models/OrderItem.dart';

class AdvancePreparationCounter extends StatefulWidget {
  final List<Order> orders;

  const AdvancePreparationCounter({Key? key, required this.orders})
      : super(key: key);

  @override
  _AdvancePreparationCounterState createState() =>
      _AdvancePreparationCounterState();
}

class _AdvancePreparationCounterState extends State<AdvancePreparationCounter> {
  Map<String, int> _itemCounts = {};

  @override
  void initState() {
    super.initState();
    _updateItemCounts();
  }

  @override
  void didUpdateWidget(covariant AdvancePreparationCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.orders != oldWidget.orders) {
      _updateItemCounts();
    }
  }

  void _updateItemCounts() {
    Map<String, int> itemCounts = {};
    widget.orders
        .expand((order) => order.orderItems ?? [])
        .where((item) =>
            item.isBeingPreparedInAdvance == true &&
            item.status != OrderItemStatus.prepared)
        .forEach((item) {
      final name = item.productVariant?.name ??
          item.product?.name ??
          'Producto desconocido';
      itemCounts[name] = (itemCounts[name] ?? 0) + 1;
    });
    setState(() {
      _itemCounts = itemCounts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 8.0,
      bottom: 80.0,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.20,
        height: 270,
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preparación anticipada',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
            SizedBox(height: 4.0),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 4.0, // Espacio entre columnas
                mainAxisSpacing: 4.0, // Espacio entre filas
                childAspectRatio:
                    7, // Ajusta según necesidad para el tamaño del texto
                children: _itemCounts.entries.map((entry) {
                  return RichText(
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
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
