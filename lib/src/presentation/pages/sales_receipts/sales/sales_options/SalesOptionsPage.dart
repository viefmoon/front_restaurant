import 'package:restaurante/src/presentation/pages/sales_receipts/sales/order_update/OpenOrdersPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales/order_creation/OrderCreationContainer.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales/order_creation/bloc/OrderCreationBloc.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales/order_creation/bloc/OrderCreationEvent.dart';

class SalesOptionsPage extends StatefulWidget {
  @override
  _SalesOptionsPageState createState() => _SalesOptionsPageState();
}

class _SalesOptionsPageState extends State<SalesOptionsPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => OrderCreationContainer()),
              ).then((_) {
                BlocProvider.of<OrderCreationBloc>(context, listen: false)
                    .add(ResetOrder());
              });
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 70, vertical: 40),
            ),
            child: Text('Crear orden', style: TextStyle(fontSize: 40)),
          ),
          SizedBox(height: 20), // Espacio entre botones
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OpenOrdersPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 70, vertical: 40),
            ),
            child: Text('Órdenes abiertas', style: TextStyle(fontSize: 40)),
          ),
        ],
      ),
    );
  }
}
