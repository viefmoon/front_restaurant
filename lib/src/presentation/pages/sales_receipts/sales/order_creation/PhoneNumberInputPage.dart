import 'package:restaurante/src/presentation/pages/sales_receipts/sales/order_creation/bloc/OrderCreationBloc.dart';
import 'package:restaurante/src/presentation/pages/sales_receipts/sales/order_creation/bloc/OrderCreationEvent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PhoneNumberInputPage extends StatelessWidget {
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width:
                    double.infinity, // Hace que la caja de texto sea más grande
                child: TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Número de teléfono',
                    border:
                        OutlineInputBorder(), // Añade un borde a la caja de texto
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ),
              SizedBox(height: 30), // Espacio entre el TextField y el botón
              SizedBox(
                width: double.infinity, // Hace que el botón sea más grande
                height: 80, // Aumenta la altura del botón
                child: ElevatedButton(
                  onPressed: () {
                    // Dispara el evento para actualizar el estado con el número de teléfono
                    BlocProvider.of<OrderCreationBloc>(context).add(
                      PhoneNumberEntered(phoneNumber: _phoneController.text),
                    );
                    // Aquí puedes añadir lógica adicional si necesitas cambiar de página o realizar otra acción
                  },
                  child: Text('Continuar',
                      style: TextStyle(
                          fontSize: 30)), // Aumenta el tamaño del texto
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
