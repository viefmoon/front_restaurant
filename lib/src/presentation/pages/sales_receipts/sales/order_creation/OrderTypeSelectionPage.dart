import 'package:restaurante/src/domain/models/Order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales/order_creation/bloc/OrderCreationBloc.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales/order_creation/bloc/OrderCreationEvent.dart';

class OrderTypeSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final OrderCreationBloc bloc = BlocProvider.of<OrderCreationBloc>(context);

    // Estilo personalizado para los botones
    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      textStyle: TextStyle(fontSize: 45), // Tamaño de letra más grande
      padding: EdgeInsets.symmetric(
          horizontal: 50,
          vertical: 30), // Padding para hacer el botón más grande
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14), // Bordes rectangulares
      ),
    );

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                bloc.add(
                    OrderTypeSelected(selectedOrderType: OrderType.delivery));
              },
              style: buttonStyle, // Aplicar el estilo personalizado
              child: Text('Para llevar'),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                bloc.add(
                    OrderTypeSelected(selectedOrderType: OrderType.dineIn));
              },
              style: buttonStyle,
              child: Text('Comer dentro'),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                bloc.add(
                    OrderTypeSelected(selectedOrderType: OrderType.pickUpWait));
              },
              style: buttonStyle,
              child: Text('Pasan/Esperan'),
            ),
          ],
        ),
      ),
    );
  }
}
